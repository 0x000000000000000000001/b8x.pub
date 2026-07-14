module Infra.Projection.Postgres.Projection where

import Proem

import Control.Parallel (parTraverse)
import Core.Mod.Projection.Pair (Key)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps(..), indexPaths)
import Core.Mod.Projection.SearchIndex (IndexPaths)
import Core.Mod.Projection.SyncProject (SyncProject(..))
import Foreign (Foreign)
import Foreign as Foreign
import Yoga.JSON (readImpl, writeImpl)
import Foreign.Index (readProp)
import Control.Monad.Except (runExcept)
import Data.Array as Array
import Data.Either (Either(..), hush, isLeft)
import Data.Foldable (traverse_)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.Set as Set
import Data.String (Pattern(..), Replacement(..), replaceAll)
import Data.String as String
import Data.Symbol (class IsSymbol)
import Data.Tuple (Tuple(..))
import Effect.Aff (attempt)
import Foreign.Object as Object
import Infra.Client.Postgres.Postgres (READER_POSTGRES_EDGE_CLIENT, READER_POSTGRES_STORE_CLIENT)
import Infra.Client.Postgres.Postgres as Postgres
import Infra.Cache.Fs.Cache (cacheDir)
import Node.FS.Aff as FS
import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist(..), Value(..))
import Infra.Projection.Projector (project_, projectionSchemaName, writeModelHashCacheMirror)
import Prim.Row as Row
import Prim.Symbol (class Append)
import Run (AFF, EFFECT, Run)
import Run.State as Run
import Run.State as State
import Type.Row (type (+))
import Util.Aff (ʌ')
import Util.Run.Router (RouterBuilder)
import Util.Run.Router as Router
import Util.Type.String.String (caseToSnake, frenchStopWords, normalizeForTextSearch)

handleProjectionWriteOps
  :: ∀ @p name copyOnWriteStateEffSym fx a
   . IsProjection p name _ _ _ _ _ _
  => IsSymbol name
  => Append name "ProjectionWriteCopyState" copyOnWriteStateEffSym
  => IsSymbol copyOnWriteStateEffSym
  => Row.Cons copyOnWriteStateEffSym (Run.State CopyOnWrite) _ (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx)
  => ProjectionWriteOps a
  -> Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) a
handleProjectionWriteOps op = do
  case op of
    Add key value next -> do
      State.modifyAt (π :: Π copyOnWriteStateEffSym) $ Map.insert key (Local (Just value))
      η next

    Get key next -> do
      value <- copy @p key
      η $ next value

    Put key value next -> do
      State.modifyAt (π :: Π copyOnWriteStateEffSym) $ Map.insert key (Local (Just value))
      η next

    Patch key f next -> do
      maybeValue <- copy @p key
      case maybeValue of
        Just value -> do
          let newValue = f value
          State.modifyAt (π :: Π copyOnWriteStateEffSym) $ Map.insert key (Local (Just newValue))
        Nothing -> η ι
      η next

    Delete key next -> do
      State.modifyAt (π :: Π copyOnWriteStateEffSym) $ Map.insert key (Local Nothing)
      η next

handleProjectionWriteCopyPersist
  :: ∀ @p name copyOnWriteStateEffSym fx a
   . IsProjection p name _ _ _ _ _ _
  => IsSymbol name
  => IsSymbol copyOnWriteStateEffSym
  => Append name "ProjectionWriteCopyState" copyOnWriteStateEffSym
  => Row.Cons copyOnWriteStateEffSym (Run.State CopyOnWrite) _ (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx)
  => ProjectionPersist a
  -> Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) a
handleProjectionWriteCopyPersist (Persist next) = do
  cache <- State.getAt (π :: Π copyOnWriteStateEffSym)

  let
    localValues :: Array (Tuple Key Value)
    localValues = (Map.toUnfoldable cache :: Array (Tuple Key Value)) # Array.filter
      ( \(Tuple _ value) -> case value of
          Local _ -> true
          Remote _ -> false
      )

  localValues # traverse_ \(Tuple key value) -> case value of
    Local (Just value_) -> do -- Upsert
      let
        innerKey = unwrap key
        tableName = innerKey.pluralType

        primaryKey = innerKey.primary ??⇒ ""
        aliases = innerKey.aliases

        -- Note: A scalar JSONB value uniquely constrains null collisions on 'null'::jsonb effectively.
        sql = "INSERT INTO " <> Postgres.escapeIdentifier (projectionSchemaName @name) <> "." <> Postgres.escapeIdentifier (caseToSnake tableName) <> " (key, key_aliases, value) VALUES ($1, $2, $3) ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, key_aliases = EXCLUDED.key_aliases, updated_at = (NOW() AT TIME ZONE 'UTC') RETURNING EXTRACT(EPOCH FROM updated_at)::varchar AS updated_at"

        normalizedValue = injectSearchOptimizedFields (indexPaths @p innerKey.singularType) (writeImpl value_)

        params = [ writeImpl primaryKey, writeImpl aliases, normalizedValue ]

      rows <- queryWithRetry @p innerKey.singularType tableName sql params

      case rows of
        [ row ] ->
          case runExcept (readImpl row) of
            Right (obj :: { updated_at :: String }) -> do
              writeModelHashCacheMirror (projectionSchemaName @name) (Just key) obj.updated_at
            _ -> ηι
        _ -> ηι

    Local Nothing -> do -- Delete
      let
        innerKey = unwrap key
        tableName = innerKey.pluralType

        primaryKey = innerKey.primary ??⇒ ""

        sql = "DELETE FROM " <> Postgres.escapeIdentifier (projectionSchemaName @name) <> "." <> Postgres.escapeIdentifier (caseToSnake tableName) <> " WHERE key = $1 RETURNING key_aliases"

        params = [ writeImpl primaryKey ]

      rows <- queryWithRetry @p innerKey.singularType tableName sql params
      
      let
        deletedAliases = case rows of
          [ row ] -> case runExcept (readProp "key_aliases" row >>= readImpl) of
            Right (al :: Array String) -> al
            _ -> []
          _ -> []

      let allKeys = [ primaryKey ] <> deletedAliases
      
      allKeys # traverse_ \k -> do
        let hashFileName = cacheDir <> "/" <> caseToSnake (projectionSchemaName @name) <> "_" <> caseToSnake innerKey.pluralType <> "_" <> k <> "_hash.json"
        ø $ ʌ' $ attempt $ FS.unlink hashFileName

    _ -> ηι

  State.putAt (π :: Π copyOnWriteStateEffSym) Map.empty

  let didModify = Array.length localValues > 0

  η $ next didModify

copy
  :: ∀ @p name copyOnWriteStateEffSym fx
   . IsProjection p name _ _ _ _ _ _
  => IsSymbol name
  => Append name "ProjectionWriteCopyState" copyOnWriteStateEffSym
  => IsSymbol copyOnWriteStateEffSym
  => Row.Cons copyOnWriteStateEffSym (Run.State CopyOnWrite) _ (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx)
  => Key
  -> Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) (Maybe Foreign)
copy key = do
  cache <- State.getAt (π :: Π copyOnWriteStateEffSym)

  case Map.lookup key cache of
    Just (Remote v) -> η v
    Just (Local v) -> η v

    Nothing -> do
      let
        innerKey = unwrap key
        tableName = innerKey.pluralType

      let
        sql = "SELECT value FROM " <> Postgres.escapeIdentifier (projectionSchemaName @name) <> "." <> Postgres.escapeIdentifier (caseToSnake tableName) <> " WHERE key = $1"
        params = [ writeImpl $ (unwrap key).primary ??⇒ "" ]

      rows <- queryWithRetry @p innerKey.singularType tableName sql params

      let
        result = case rows of
          [ row ] ->
            case runExcept (readImpl row >>= readProp "value") of
              Left _ -> Nothing
              Right value -> Just value
          _ -> Nothing

      State.modifyAt (π :: Π copyOnWriteStateEffSym) $ Map.insert key (Remote result)

      η result

queryWithRetry
  :: ∀ @p name fx
   . IsProjection p name _ _ _ _ _ _
  => IsSymbol name
  => String
  -> String
  -> String
  -> Array Foreign
  -> Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) (Array Foreign)
queryWithRetry singularType tableName sql params = do
  resOrErr <- Postgres.tryQueryEdge sql params
  case resOrErr of
    Right r -> η r
    Left _ -> do
      ensureProjectionTable @p singularType tableName
      Postgres.queryEdge sql params

ensureProjectionTable
  :: ∀ @p name fx
   . IsProjection p name _ _ _ _ _ _
  => IsSymbol name
  => String
  -> String
  -> Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) Ɩ
ensureProjectionTable singularType tableName = ø $ Postgres.queryEdge (tableCreationSql (projectionSchemaName @name) tableName (indexPaths @p singularType)) []

tableCreationSql :: String -> String -> IndexPaths -> String
tableCreationSql schemaNameRaw tableNameRaw indexPaths =
  let
    schemaName = caseToSnake schemaNameRaw
    tableName = caseToSnake tableNameRaw

    sanitizedSchemaName = replaceAll (Pattern ".") (Replacement "_") schemaName
    sanitizedTableName = replaceAll (Pattern ".") (Replacement "_") tableName

    escapedSchemaName = Postgres.escapeIdentifier schemaName
    escapedTableName = Postgres.escapeIdentifier tableName
    fullTableName = escapedSchemaName <> "." <> escapedTableName

    baseSql =
      """
      CREATE EXTENSION IF NOT EXISTS pg_trgm;
      CREATE EXTENSION IF NOT EXISTS rum;
      CREATE EXTENSION IF NOT EXISTS unaccent;

      CREATE SCHEMA IF NOT EXISTS fts;

      -- Centralized Text Normalization
      CREATE OR REPLACE FUNCTION fts.normalize(w text) RETURNS text AS $$
      BEGIN
          RETURN unaccent(lower(w));
      END;
      $$ LANGUAGE plpgsql IMMUTABLE;

      CREATE SCHEMA IF NOT EXISTS $escapedSchemaName;

      -- FTS Words Table
      CREATE TABLE IF NOT EXISTS $escapedSchemaName.fts_words (
          word TEXT PRIMARY KEY,
          doc_count INT DEFAULT 1
      );
      CREATE INDEX IF NOT EXISTS idx_$sanitizedSchemaName_fts_words_trgm ON $escapedSchemaName.fts_words USING gin (word gin_trgm_ops);
      CREATE INDEX IF NOT EXISTS idx_$sanitizedSchemaName_fts_words_doc_count ON $escapedSchemaName.fts_words (doc_count);

      -- FTS Word Couples Table
      CREATE TABLE IF NOT EXISTS $escapedSchemaName.fts_word_couples (
          concat_word TEXT PRIMARY KEY,
          separated_words TEXT,
          doc_count INT DEFAULT 1
      );
      CREATE INDEX IF NOT EXISTS idx_$sanitizedSchemaName_fts_word_couples_trgm ON $escapedSchemaName.fts_word_couples USING gin (concat_word gin_trgm_ops);
      CREATE INDEX IF NOT EXISTS idx_$sanitizedSchemaName_fts_word_couples_doc_count ON $escapedSchemaName.fts_word_couples (doc_count);

      -- FTS Dictionary Candidates Extraction
      CREATE OR REPLACE FUNCTION fts.find_candidates(schema_name text, w text) RETURNS text[] AS $$
      DECLARE
          candidates text[];
          w_arr text[];
      BEGIN
          IF length(w) < 4 THEN
              RETURN ARRAY[w];
          END IF;
          
          IF length(w) < 6 THEN
              PERFORM set_config('pg_trgm.similarity_threshold', '0.20', true);
          ELSIF length(w) < 8 THEN
              PERFORM set_config('pg_trgm.similarity_threshold', '0.25', true);
          ELSE
              PERFORM set_config('pg_trgm.similarity_threshold', '0.35', true);
          END IF;

          w_arr := string_to_array(w, NULL);

          EXECUTE format('
              SELECT array_agg(ranked.word) FROM (
                  SELECT sub.word 
                  FROM (
                      SELECT d.word, 
                             d.doc_count,
                             (SELECT count(*) FROM (SELECT unnest($2) INTERSECT SELECT unnest(string_to_array(d.word, NULL))) x)::float AS overlap,
                             (SELECT count(DISTINCT x) FROM unnest(string_to_array(d.word, NULL)) AS t(x))::float AS unique_len
                      FROM %I.fts_words d 
                      WHERE d.word %% $1
                  ) sub
                  WHERE abs(sub.unique_len - (SELECT count(DISTINCT x) FROM unnest($2) AS t(x))::float) <= 2.0
                    AND abs(length(sub.word) - length($1)) <= 2
                  ORDER BY 
                      (sub.word LIKE $1 || ''%%'') DESC,
                      (left(sub.word, 1) = left($1, 1) OR (length($1) >= 2 AND left(sub.word, 2) = substring($1 from 2 for 1) || left($1, 1))) DESC,
                      sub.overlap DESC,
                      (sub.overlap / GREATEST(sub.unique_len, 1.0)) DESC,
                      similarity(sub.word, $1) DESC,
                      sub.doc_count DESC
                  LIMIT 8
              ) ranked;
          ', schema_name) INTO candidates USING w, w_arr;

          RETURN coalesce(candidates, ARRAY[]::text[]);
      END;
      $$ LANGUAGE plpgsql STABLE;

      -- FTS Dictionary Query Expansion
      CREATE OR REPLACE FUNCTION fts.expand_query(schema_name text, search_query text, quick_nothing_better_than_slower_something boolean DEFAULT false) RETURNS tsquery AS $$
      DECLARE
          words text[];
          clauses text[] := ARRAY[]::text[];
          candidates text[];
          w text;
          best_couple text;
          single_clause text;
          couple_clause text;
          expanded text;
          word_exists boolean;
      BEGIN
          search_query := regexp_replace(search_query, '[[:punct:]]', ' ', 'g');
          words := regexp_split_to_array(trim(search_query), '\s+');
          IF array_length(words, 1) IS NULL THEN
              RETURN websearch_to_tsquery('french'::regconfig, search_query);
          END IF;

          FOR i IN 1..array_length(words, 1) LOOP
              w := words[i];
              IF w = '' THEN CONTINUE; END IF;
              
              w := fts.normalize(w);
              
              IF w IN ($frenchStopWords) OR length(to_tsvector('french'::regconfig, w)) = 0 THEN
                  CONTINUE;
              END IF;
              
              -- 1. Single word candidates
              EXECUTE format('SELECT EXISTS(SELECT 1 FROM %I.fts_words WHERE word = $1)', schema_name) INTO word_exists USING w;
              IF word_exists THEN
                  candidates := ARRAY[w];
              ELSE
                  candidates := fts.find_candidates(schema_name, w);
              END IF;
              
              single_clause := '';
              IF array_length(candidates, 1) > 0 THEN
                  single_clause := '(' || array_to_string(candidates, ' | ') || ')';
              ELSE
                  single_clause := w;
              END IF;

              -- 2. Word couple candidates
              couple_clause := '';
              -- Why not "AND NOT word_exists"? Consider "socio-économique" and "socioéconomique" (both are correct)
              IF NOT quick_nothing_better_than_slower_something AND length(w) >= 6 THEN
                  PERFORM set_config('pg_trgm.similarity_threshold', '0.33', true);
                  
                  EXECUTE format('
                      SELECT separated_words 
                      FROM %I.fts_word_couples 
                      WHERE concat_word %% $1
                        AND abs(length(concat_word) - length($1)) <= 1
                      ORDER BY similarity(concat_word, $1) DESC, doc_count DESC 
                      LIMIT 1
                  ', schema_name) INTO best_couple USING w;
                  
                  IF best_couple IS NOT NULL THEN
                      couple_clause := '(' || replace(best_couple, ' ', ' & ') || ')';
                  END IF;
              END IF;

              -- 3. Combine clauses
              IF couple_clause <> '' THEN
                  clauses := array_append(clauses, '(' || single_clause || ' | ' || couple_clause || ')');
              ELSE
                  clauses := array_append(clauses, single_clause);
              END IF;
          END LOOP;

          IF array_length(clauses, 1) IS NULL THEN
              RETURN websearch_to_tsquery('french'::regconfig, search_query);
          END IF;

          IF quick_nothing_better_than_slower_something THEN
              expanded := array_to_string(clauses, ' & ');
          ELSE
              expanded := array_to_string(clauses, ' | ');
          END IF;

          BEGIN
              RETURN to_tsquery('french'::regconfig, expanded);
          EXCEPTION WHEN OTHERS THEN
              RETURN websearch_to_tsquery('french'::regconfig, search_query);
          END;
      END;
      $$ LANGUAGE plpgsql STABLE;
      
      CREATE TABLE IF NOT EXISTS $fullTableName (
        n BIGSERIAL PRIMARY KEY,
        key VARCHAR NOT NULL,
        key_aliases TEXT[] NOT NULL DEFAULT '{}',
        value JSONB NOT NULL,
        updated_at TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC')
      );

      CREATE UNIQUE INDEX IF NOT EXISTS idx_$sanitizedSchemaName_$sanitizedTableName_key ON $fullTableName (key);
      CREATE INDEX IF NOT EXISTS idx_$sanitizedSchemaName_$sanitizedTableName_key_aliases ON $fullTableName USING gin(key_aliases);
      CREATE INDEX IF NOT EXISTS idx_$sanitizedSchemaName_$sanitizedTableName_value ON $fullTableName USING gin(value);
      """
        # replaceAll (Pattern "$escapedSchemaName") (Replacement escapedSchemaName)
        # replaceAll (Pattern "$fullTableName") (Replacement fullTableName)
        # replaceAll (Pattern "$sanitizedSchemaName") (Replacement sanitizedSchemaName)
        # replaceAll (Pattern "$sanitizedTableName") (Replacement sanitizedTableName)
        # replaceAll (Pattern "$frenchStopWords") (Replacement (String.joinWith ", " (frenchStopWords <#> (\w -> "'" <> w <> "'"))))

    buildRaw pathParts =
      let
        path = String.joinWith "." pathParts
        jsonPathText = case Array.length pathParts of
          1 -> "->>'" <> path <> "'"
          _ -> "#>>'{" <> String.joinWith "," pathParts <> "}'"
        jsonPathJsonb = case Array.length pathParts of
          1 -> "->'" <> path <> "'"
          _ -> "#>'{" <> String.joinWith "," pathParts <> "}'"
        sanitizedPathForIndexName = String.joinWith "_" pathParts
      in
        "CREATE INDEX IF NOT EXISTS idx_$sanitizedSchemaName_$sanitizedTableName_value_$sanitizedPathForIndexName ON $fullTableName ((value$jsonPathText));\n"
          <> "CREATE INDEX IF NOT EXISTS idx_$sanitizedSchemaName_$sanitizedTableName_value_$sanitizedPathForIndexName_jsonb ON $fullTableName ((value$jsonPathJsonb));\n"
          # replaceAll (Pattern "$sanitizedSchemaName") (Replacement sanitizedSchemaName)
          # replaceAll (Pattern "$sanitizedTableName") (Replacement sanitizedTableName)
          # replaceAll (Pattern "$fullTableName") (Replacement fullTableName)
          # replaceAll (Pattern "$sanitizedPathForIndexName") (Replacement sanitizedPathForIndexName)
          # replaceAll (Pattern "$jsonPathText") (Replacement jsonPathText)
          # replaceAll (Pattern "$jsonPathJsonb") (Replacement jsonPathJsonb)

    buildNorm pathParts =
      let
        path = String.joinWith "." pathParts
        jsonPath = case Array.length pathParts of
          1 -> "->>'_" <> path <> "'"
          _ ->
            let
              mapped = pathParts # Array.mapWithIndex \j p -> j == Array.length pathParts - 1 ? ("_" <> p) ↔ p
            in
              "#>>'{" <> String.joinWith "," mapped <> "}'"
        sanitizedPathForIndexName = String.joinWith "_" pathParts
      in
        "CREATE INDEX IF NOT EXISTS idx_$sanitizedSchemaName_$sanitizedTableName_value_$sanitizedPathForIndexName_norm ON $fullTableName ((value$jsonPath));\n"
          # replaceAll (Pattern "$sanitizedSchemaName") (Replacement sanitizedSchemaName)
          # replaceAll (Pattern "$sanitizedTableName") (Replacement sanitizedTableName)
          # replaceAll (Pattern "$fullTableName") (Replacement fullTableName)
          # replaceAll (Pattern "$sanitizedPathForIndexName") (Replacement sanitizedPathForIndexName)
          # replaceAll (Pattern "$jsonPath") (Replacement jsonPath)

    buildTs pathParts =
      let
        path = String.joinWith "." pathParts

        rawNormalizedJsonPath = case Array.length pathParts of
          1 -> "->>'_" <> path <> "'"
          _ ->
            let
              mapped = pathParts # Array.mapWithIndex \j p -> j == Array.length pathParts - 1 ? ("_" <> p) ↔ p
            in
              "#>>'{" <> String.joinWith "," mapped <> "}'"

        sanitizedPathForIndexName = String.joinWith "_" pathParts
      in
        -- A classical B-Tree index would refuse too long strings.
        """
        ALTER TABLE $fullTableName ADD COLUMN IF NOT EXISTS value_$sanitizedPathForIndexName_tsvector tsvector GENERATED ALWAYS AS (to_tsvector('french'::regconfig, value$rawNormalizedJsonPath)) STORED;

        CREATE INDEX IF NOT EXISTS idx_$sanitizedSchemaName_$sanitizedTableName_value_$sanitizedPathForIndexName_fts_ts ON $fullTableName USING rum (value_$sanitizedPathForIndexName_tsvector);

        -- Auto-population Trigger
        CREATE OR REPLACE FUNCTION $escapedSchemaName.trg_func_$sanitizedTableName_value_$sanitizedPathForIndexName_into_fts_words() RETURNS TRIGGER AS $$
        DECLARE
            new_arr text[];
            old_arr text[];
        BEGIN
            -- Short-circuit optimization to dramatically boost irrelevant field updates
            IF TG_OP = 'UPDATE' AND coalesce(NEW.value$rawNormalizedJsonPath, '') = coalesce(OLD.value$rawNormalizedJsonPath, '') THEN
                RETURN NULL;
            END IF;

            IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
                new_arr := regexp_split_to_array(fts.normalize(coalesce(NEW.value$rawNormalizedJsonPath, '')), '[^a-z0-9]+');
            END IF;
            IF TG_OP = 'DELETE' OR TG_OP = 'UPDATE' THEN
                old_arr := regexp_split_to_array(fts.normalize(coalesce(OLD.value$rawNormalizedJsonPath, '')), '[^a-z0-9]+');
            END IF;

            IF TG_OP = 'INSERT' THEN
                -- Insert individual words
                INSERT INTO $escapedSchemaName.fts_words (word)
                SELECT DISTINCT unnest FROM unnest(new_arr) WHERE length(unnest) >= 3
                ON CONFLICT (word) DO UPDATE SET doc_count = fts_words.doc_count + 1;
                
                -- Insert word couples (bigrams)
                INSERT INTO $escapedSchemaName.fts_word_couples (concat_word, separated_words)
                SELECT t1.word || t2.word, MAX(t1.word || ' ' || t2.word)
                FROM unnest(new_arr) WITH ORDINALITY AS t1(word, rn)
                JOIN unnest(new_arr) WITH ORDINALITY AS t2(word, rn) ON t2.rn = t1.rn + 1
                WHERE t1.word <> '' AND t2.word <> '' AND length(t1.word || t2.word) >= 6
                GROUP BY t1.word || t2.word
                ON CONFLICT (concat_word) DO UPDATE SET doc_count = fts_word_couples.doc_count + 1;

            ELSIF TG_OP = 'UPDATE' THEN
                -- Words added
                INSERT INTO $escapedSchemaName.fts_words (word)
                SELECT unnest FROM unnest(new_arr) WHERE length(unnest) >= 3
                EXCEPT
                SELECT unnest FROM unnest(old_arr) WHERE length(unnest) >= 3
                ON CONFLICT (word) DO UPDATE SET doc_count = fts_words.doc_count + 1;

                -- Word Couples added
                INSERT INTO $escapedSchemaName.fts_word_couples (concat_word, separated_words)
                SELECT added_concat, MAX(added_sep) FROM (
                    SELECT t1.word || t2.word AS added_concat, t1.word || ' ' || t2.word AS added_sep
                    FROM unnest(new_arr) WITH ORDINALITY AS t1(word, rn)
                    JOIN unnest(new_arr) WITH ORDINALITY AS t2(word, rn) ON t2.rn = t1.rn + 1
                    WHERE t1.word <> '' AND t2.word <> '' AND length(t1.word || t2.word) >= 6
                    EXCEPT
                    SELECT t1.word || t2.word AS added_concat, t1.word || ' ' || t2.word AS added_sep
                    FROM unnest(old_arr) WITH ORDINALITY AS t1(word, rn)
                    JOIN unnest(old_arr) WITH ORDINALITY AS t2(word, rn) ON t2.rn = t1.rn + 1
                    WHERE t1.word <> '' AND t2.word <> '' AND length(t1.word || t2.word) >= 6
                ) sub
                GROUP BY added_concat
                ON CONFLICT (concat_word) DO UPDATE SET doc_count = fts_word_couples.doc_count + 1;

                -- Words removed
                WITH decremented_words AS (
                    UPDATE $escapedSchemaName.fts_words
                    SET doc_count = fts_words.doc_count - 1
                    WHERE word IN (
                        SELECT unnest FROM unnest(old_arr) WHERE length(unnest) >= 3
                        EXCEPT
                        SELECT unnest FROM unnest(new_arr) WHERE length(unnest) >= 3
                    )
                    RETURNING word, doc_count
                )
                DELETE FROM $escapedSchemaName.fts_words WHERE word IN (SELECT word FROM decremented_words WHERE doc_count <= 0);
                
                -- Word couples removed
                WITH decremented_couples AS (
                    UPDATE $escapedSchemaName.fts_word_couples
                    SET doc_count = fts_word_couples.doc_count - 1
                    WHERE concat_word IN (
                        SELECT t1.word || t2.word
                        FROM unnest(old_arr) WITH ORDINALITY AS t1(word, rn)
                        JOIN unnest(old_arr) WITH ORDINALITY AS t2(word, rn) ON t2.rn = t1.rn + 1
                        WHERE t1.word <> '' AND t2.word <> '' AND length(t1.word || t2.word) >= 6
                        EXCEPT
                        SELECT t1.word || t2.word
                        FROM unnest(new_arr) WITH ORDINALITY AS t1(word, rn)
                        JOIN unnest(new_arr) WITH ORDINALITY AS t2(word, rn) ON t2.rn = t1.rn + 1
                        WHERE t1.word <> '' AND t2.word <> '' AND length(t1.word || t2.word) >= 6
                    )
                    RETURNING concat_word, doc_count
                )
                DELETE FROM $escapedSchemaName.fts_word_couples WHERE concat_word IN (SELECT concat_word FROM decremented_couples WHERE doc_count <= 0);
                
            ELSIF TG_OP = 'DELETE' THEN
                -- Words removed
                WITH decremented_words AS (
                    UPDATE $escapedSchemaName.fts_words
                    SET doc_count = fts_words.doc_count - 1
                    WHERE word IN (
                        SELECT DISTINCT unnest FROM unnest(old_arr) WHERE length(unnest) >= 3
                    )
                    RETURNING word, doc_count
                )
                DELETE FROM $escapedSchemaName.fts_words WHERE word IN (SELECT word FROM decremented_words WHERE doc_count <= 0);
                
                -- Word couples removed
                WITH decremented_couples AS (
                    UPDATE $escapedSchemaName.fts_word_couples
                    SET doc_count = fts_word_couples.doc_count - 1
                    WHERE concat_word IN (
                        SELECT t1.word || t2.word
                        FROM unnest(old_arr) WITH ORDINALITY AS t1(word, rn)
                        JOIN unnest(old_arr) WITH ORDINALITY AS t2(word, rn) ON t2.rn = t1.rn + 1
                        WHERE t1.word <> '' AND t2.word <> '' AND length(t1.word || t2.word) >= 6
                    )
                    RETURNING concat_word, doc_count
                )
                DELETE FROM $escapedSchemaName.fts_word_couples WHERE concat_word IN (SELECT concat_word FROM decremented_couples WHERE doc_count <= 0);
            END IF;
            RETURN NULL;
        END;
        $$ LANGUAGE plpgsql;

        DROP TRIGGER IF EXISTS trg_$sanitizedTableName_value_$sanitizedPathForIndexName_into_fts_words ON $fullTableName;
        CREATE TRIGGER trg_$sanitizedTableName_value_$sanitizedPathForIndexName_into_fts_words
        AFTER INSERT OR UPDATE OR DELETE ON $fullTableName
        FOR EACH ROW EXECUTE FUNCTION $escapedSchemaName.trg_func_$sanitizedTableName_value_$sanitizedPathForIndexName_into_fts_words();
        """
          # replaceAll (Pattern "$sanitizedSchemaName") (Replacement sanitizedSchemaName)
          # replaceAll (Pattern "$escapedSchemaName") (Replacement escapedSchemaName)
          # replaceAll (Pattern "$sanitizedTableName") (Replacement sanitizedTableName)
          # replaceAll (Pattern "$fullTableName") (Replacement fullTableName)
          # replaceAll (Pattern "$sanitizedPathForIndexName") (Replacement sanitizedPathForIndexName)
          # replaceAll (Pattern "$rawNormalizedJsonPath") (Replacement rawNormalizedJsonPath)

    buildGlobalTs indexPaths' =
      let
        buildWeight :: String -> Array (Array String) -> Maybe String
        buildWeight _ [] = Nothing
        buildWeight weight paths =
          let
            coalesces = paths <#> \pathParts ->
              let
                jsonPath = case Array.length pathParts of
                  1 -> "->>'_" <> String.joinWith "." pathParts <> "'"
                  _ ->
                    let
                      mapped = pathParts # Array.mapWithIndex \j p -> j == Array.length pathParts - 1 ? ("_" <> p) ↔ p
                    in
                      "#>>'{" <> String.joinWith "," mapped <> "}'"
              in
                "coalesce(value" <> jsonPath <> ", '')"
            concatenated = String.joinWith " || ' ' || " coalesces
          in
            Just ("setweight(to_tsvector('french'::regconfig, " <> concatenated <> "), '" <> weight <> "')")

        weights = Array.catMaybes
          [ buildWeight "A" indexPaths'.fullTextA
          , buildWeight "B" indexPaths'.fullTextB
          , buildWeight "C" indexPaths'.fullTextC
          , buildWeight "D" indexPaths'.fullTextD
          ]
      in
        if Array.null weights then ""
        else
          let
            concatenated = String.joinWith " || " weights
          in
            "ALTER TABLE $fullTableName ADD COLUMN IF NOT EXISTS value_tsvector tsvector GENERATED ALWAYS AS (" <> concatenated <> ") STORED;\n"
              <> "CREATE INDEX IF NOT EXISTS idx_$sanitizedSchemaName_$sanitizedTableName_value_tsvector ON $fullTableName USING rum (value_tsvector);\n"
              # replaceAll (Pattern "$sanitizedSchemaName") (Replacement sanitizedSchemaName)
              # replaceAll (Pattern "$sanitizedTableName") (Replacement sanitizedTableName)
              # replaceAll (Pattern "$fullTableName") (Replacement fullTableName)

    allFullText = indexPaths.fullTextA <> indexPaths.fullTextB <> indexPaths.fullTextC <> indexPaths.fullTextD
    rawSql = indexPaths.raw # map buildRaw # String.joinWith ""
    normSql = indexPaths.normalized # map buildNorm # String.joinWith ""
    tsSql = allFullText # map buildTs # String.joinWith ""
    globalTsSql = buildGlobalTs indexPaths
  in
    baseSql <> "\n" <> rawSql <> normSql <> tsSql <> globalTsSql

injectSearchOptimizedFields :: IndexPaths -> Foreign -> Foreign
injectSearchOptimizedFields indexPaths json =
  let
    allFullText = indexPaths.fullTextA <> indexPaths.fullTextB <> indexPaths.fullTextC <> indexPaths.fullTextD
    normPathArrays = Array.fromFoldable $ Set.fromFoldable (indexPaths.normalized <> allFullText)
  in
    go normPathArrays json
  where
  go :: Array (Array String) -> Foreign -> Foreign
  go currentNormPaths currentJson =
    case runExcept (readImpl currentJson) of
      Left _ -> currentJson
      Right (obj :: Object.Object Foreign) ->
        Foreign.unsafeToForeign $ Object.fold
          ( \acc k v ->
              let
                matchingNormPaths = currentNormPaths # Array.filter (\p -> Array.head p == Just k)
                isNormLeaf = matchingNormPaths # Array.any (\p -> Array.length p == 1)
                deeperNormPaths = matchingNormPaths # Array.mapMaybe (\p -> Array.length p > 1 ? (Just $ Array.drop 1 p) ↔ Nothing)

                normalizedInnerValue = (Array.length deeperNormPaths > 0) ? (go deeperNormPaths v) ↔ v
                acc' = Object.insert k normalizedInnerValue acc
              in
                case isNormLeaf of
                  false -> acc'
                  true -> case runExcept (Foreign.readString normalizedInnerValue) of
                    Right s ->
                      let
                        strNorm = Foreign.unsafeToForeign (normalizeForTextSearch s)
                      in
                        Object.insert ("_" <> k) strNorm acc'
                    Left _ -> case runExcept (Foreign.readArray normalizedInnerValue) of
                      Right arr ->
                        let
                          normalizeElem elem = Foreign.unsafeToForeign ◁ normalizeForTextSearch <$> hush (runExcept (Foreign.readString elem))
                          arrNorm = Foreign.unsafeToForeign (Array.mapMaybe normalizeElem arr)
                        in
                          Object.insert ("_" <> k) arrNorm acc'
                      Left _ -> acc'
          )
          Object.empty
          obj

onProjectionWriteOps
  :: ∀ @p name opsEffSym opsEff copyOnWriteStateEffSym fx a
   . IsProjection p name opsEffSym opsEff _ _ _ _
  => IsSymbol name
  => Append name "ProjectionWriteCopyState" copyOnWriteStateEffSym
  => IsSymbol opsEffSym
  => IsSymbol copyOnWriteStateEffSym
  => Row.Cons copyOnWriteStateEffSym (Run.State CopyOnWrite) _ (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx)
  => RouterBuilder (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) a
  -> RouterBuilder (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) a
onProjectionWriteOps = Router.on @opsEffSym (handleProjectionWriteOps @p)

onProjectionWriteCopyPersist
  :: ∀ @p name copyOnWritePersistEffSym copyOnWriteStateEffSym fx a
   . IsProjection p name _ _ _ _ _ _
  => IsSymbol name
  => Append name "ProjectionWriteCopyPersist" copyOnWritePersistEffSym
  => Append name "ProjectionWriteCopyState" copyOnWriteStateEffSym
  => IsSymbol copyOnWritePersistEffSym
  => IsSymbol copyOnWriteStateEffSym
  => Row.Cons copyOnWriteStateEffSym (Run.State CopyOnWrite) _ (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx)
  => RouterBuilder (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) a
  -> RouterBuilder (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) a
onProjectionWriteCopyPersist = Router.on @copyOnWritePersistEffSym (handleProjectionWriteCopyPersist @p)

onProjectionReadSyncProject
  :: ∀ @p name opsEffSym opsEff syncEffSym copyOnWriteStateEffSym copyOnWritePersistEffSym fx a
   . IsProjection p name opsEffSym opsEff syncEffSym _ _ _
  => IsSymbol name
  => Append name "ProjectionWriteCopyState" copyOnWriteStateEffSym
  => Append name "ProjectionWriteCopyPersist" copyOnWritePersistEffSym
  => IsSymbol syncEffSym
  => IsSymbol opsEffSym
  => IsSymbol copyOnWriteStateEffSym
  => IsSymbol copyOnWritePersistEffSym
  => Row.Cons copyOnWriteStateEffSym (Run.State CopyOnWrite) _ (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => Row.Cons copyOnWritePersistEffSym ProjectionPersist _ (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => Row.Union opsEff _ (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => RouterBuilder (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) a
  -> RouterBuilder (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) a
onProjectionReadSyncProject = Router.on @syncEffSym handle
  where
  handle :: ∀ a'. SyncProject a' -> Run (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) a'
  handle (Sync next) = do
    project_ @p
    η next

onProjectionReadSyncProjectWithNoop
  :: ∀ @p syncEffSym fx a
   . IsProjection p _ _ _ syncEffSym _ _ _
  => IsSymbol syncEffSym
  => RouterBuilder fx a
  -> RouterBuilder fx a
onProjectionReadSyncProjectWithNoop = Router.on @syncEffSym handle
  where
  handle :: ∀ a'. SyncProject a' -> Run fx a'
  handle (Sync next) = η next

parQueryWithRetry
  :: ∀ @p name fx
   . IsProjection p name _ _ _ _ _ _
  => IsSymbol name
  => String
  -> String
  -> Array { sql :: String, params :: Array Foreign }
  -> Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) (Array (Array Foreign))
parQueryWithRetry singularType tableName queries = do
  handle <- Postgres.askEdgeConnectionPoolHandle
  resOrErr <- ʌ' $ parTraverse (\q -> attempt $ Postgres.query_ handle q.sql q.params) queries

  let failures = Array.filter isLeft resOrErr

  if Array.length failures > 0 then do
    ensureProjectionTable @p singularType tableName
    ʌ' $ parTraverse (\q -> Postgres.query_ handle q.sql q.params) queries
  else do
    let successes = Array.mapMaybe hush resOrErr
    η successes
