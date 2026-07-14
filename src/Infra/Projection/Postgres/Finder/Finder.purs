module Infra.Projection.Postgres.Finder.Finder where

import Proem hiding ((&&), (||))

import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation(..))
import Core.Mod.Projection.Finder.Filter (Filter, Limit(..), Op(..), fold)
import Core.Mod.Projection.Finder.Finder (Find(..))
import Core.Mod.Projection.Finder.Sort (SortDirection(..))
import Core.Mod.Projection.Pair (class IsPair)
import Core.Mod.Projection.Projection (class IsProjection)
import Foreign (Foreign)
import Yoga.JSON (readImpl, writeImpl)
import Foreign.Index (readProp)
import Control.Monad.Except (runExcept, ExceptT)
import Util.Foreign.Native as Native
import Data.Array as Array
import Data.Array (foldr, length, mapMaybe, mapWithIndex, take, (!!))
import Data.Either (Either(..), hush)
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.Number (pow)
import Data.String (Pattern(..), Replacement(..), joinWith, replaceAll)
import Data.Symbol (class IsSymbol)
import Data.Tuple.Nested ((/\))
import Foreign.Object as Object
import Infra.Client.Postgres.Postgres (READER_POSTGRES_EDGE_CLIENT)
import Infra.Client.Postgres.Postgres as Postgres
import Infra.Projection.Postgres.Projection (parQueryWithRetry)
import Infra.Projection.Projector (getReadModelHash_, projectionSchemaName)
import Partial.Unsafe (unsafeCrashWith)
import Run (AFF, EFFECT, Run)
import Type.Row (type (+))
import Util.Run.Router (RouterBuilder)
import Util.Run.Router as Router
import Util.Type.String.String (caseToSnake, normalizeForFrenchTextSearch, normalizeForTextSearch)

onProjectionReadFind
  :: ∀ @v p name singularName pluralName findEffSym fx a
   . IsProjection p name _ _ _ _ _ _
  => IsPair _ v _ _ _ singularName pluralName findEffSym p
  => IsSymbol name
  => IsSymbol findEffSym
  => IsSymbol singularName
  => IsSymbol pluralName
  => RouterBuilder (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) a
  -> RouterBuilder (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) a
onProjectionReadFind = Router.on @findEffSym (handle @v)
  where
  handle
    :: ∀ @v' p' name' singularName' pluralName' fx'' a'
     . IsProjection p' name' _ _ _ _ _ _
    => IsPair _ v' _ _ _ singularName' pluralName' findEffSym p'
    => IsSymbol name'
    => IsSymbol singularName'
    => IsSymbol pluralName'
    => Find v' a'
    -> Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx'') a'
  handle (FindMany queries next) = do
    let
      singularType = ᴠ @singularName'
      tableName = ᴠ @pluralName'
      schemaName = projectionSchemaName @name'

    let
      compiledQueries = queries <#> \query ->
        let
          { limit, after, sort, filter } = query

          { sql: whereClause, values: whereValues, score, froms: whereFroms } = case filter of
            Just f -> buildWhere (caseToSnake schemaName) f 1
            Nothing -> { sql: "true", values: [], score: Nothing, is: Leaf, froms: [] }

          fullTableName = Postgres.escapeIdentifier (caseToSnake schemaName) <> "." <> Postgres.escapeIdentifier (caseToSnake tableName)

          buildColPath alias pathParts = case length pathParts of
            1 -> alias <> ".value->'" <> joinWith "." pathParts <> "'"
            _ -> alias <> ".value#>'{" <> joinWith "," pathParts <> "}'"

          formatSort { path, direction } = buildColPath "t" path <> case direction of
            Asc -> " ASC"
            Desc -> " DESC"

          orderByCustom = if length sort > 0 then joinWith ", " (map formatSort (map unwrap sort)) <> ", " else ""

          { select: selectClause, orderBy: orderByClause } = case score of
            Just s -> { select: "t.value, (" <> s.sql <> ") AS score", orderBy: " ORDER BY score DESC, " <> orderByCustom <> "t.n DESC" }
            Nothing -> { select: "t.value", orderBy: " ORDER BY " <> orderByCustom <> "t.n DESC" }

          (cursorCte /\ whereClause' /\ whereValues') = case after of
            Just key ->
              let
                idx = length whereValues + 1

                cursorSelects = sort # map unwrap # mapWithIndex \i s -> buildColPath fullTableName s.path <> " AS c" <> show i
                cursorSelectsStr = if length cursorSelects > 0 then joinWith ", " cursorSelects <> ", " else ""
                cte = "WITH cursor AS (SELECT " <> cursorSelectsStr <> "n FROM " <> fullTableName <> " WHERE key = ($" <> show idx <> "::text)) "

                keys = (sort # map unwrap # mapWithIndex \i s -> { col: buildColPath "t" s.path, cursorCol: "cursor.c" <> show i, direction: s.direction }) <> [ { col: "t.n", cursorCol: "cursor.n", direction: Desc } ]

                buildLevel depth = case keys !! depth of
                  Nothing -> "false"
                  Just { col, cursorCol, direction } ->
                    let
                      operator = case direction of
                        Asc -> " > "
                        Desc -> " < "
                      inequality = "(" <> col <> operator <> cursorCol <> ")"
                      equality = "(" <> col <> " IS NOT DISTINCT FROM " <> cursorCol <> ")"
                    in
                      if depth == length keys - 1 then
                        inequality
                      else
                        "(" <> inequality <> " OR (" <> equality <> " AND " <> buildLevel (depth + 1) <> "))"

              in
                cte /\ ("(" <> whereClause <> ") AND " <> buildLevel 0) /\ (whereValues <> [ writeImpl $ (unwrap key).primary ??⇒ "" ])
            Nothing ->
              "" /\ whereClause /\ whereValues

          limitIdx = length whereValues' + 1

          limitClause = case limit of
            Infinite -> { limit: "", values: [] }
            Finite n -> { limit: " LIMIT $" <> show limitIdx, values: [ writeImpl (n + 1) ] }

          fromClause =
            " FROM " <> fullTableName <> " t"
              <> (if cursorCte == "" then "" else ", cursor")
              <> (if length whereFroms > 0 then ", " <> joinWith ", " whereFroms else "")

          sql = cursorCte <> "SELECT " <> selectClause <> fromClause <> " WHERE " <> whereClause' <> orderByClause <> limitClause.limit
          params = whereValues' <> limitClause.values
        in
          { sql, params, limit }

    rawResults <- parQueryWithRetry @p' singularType tableName (compiledQueries <#> \q -> { sql: q.sql, params: q.params })

    let
      results = Array.zip compiledQueries rawResults <#> \(query /\ rawRows) ->
        let
          (rows /\ hasNextPage) = case query.limit of
            Infinite -> rawRows /\ false
            Finite n ->
              if length rawRows > n then
                take n rawRows /\ true
              else
                rawRows /\ false

          result =
            rows
              # mapMaybe \row ->
                  case runExcept (readImpl row >>= readProp "value") of
                    Left _ -> Nothing
                    Right jsonVal ->
                      let
                        parsedVal = case runExcept (readImpl jsonVal :: ExceptT _ _ String) of
                          Right (s :: String) -> case Native.parseJSON s of
                            Right p -> p
                            Left _ -> jsonVal
                          Left _ -> jsonVal
                      in
                        hush $ runExcept (readImpl parsedVal)

        in
          { items: result, hasNextPage }

    η (next results)

  handle (GetReadModelHash mKey next) = do
    hash <- getReadModelHash_ (projectionSchemaName @name') mKey
    η (next hash)

data ScoreNode = Leaf | And | Or

derive instance Eq ScoreNode

type Score =
  { sql :: String
  , weight :: Number
  }

type Where =
  { sql :: String
  , values :: Array Foreign
  , score :: Maybe Score
  , is :: ScoreNode
  , froms :: Array String
  }

-- | Compiles a `Filter` Ast into a SQL `WHERE` clause and a SQL `ORDER BY` score string.
-- | 
-- | The scoring system implements a recursive, mathematically normalized tree structure:
-- | 1. **Leaf Nodes (Matches w):** 
-- |    Each leaf generates a raw score bounded strictly between `0.0` and `1.0` (using
-- |    ts_rank, similarity, etc.). It returns this score along with its developer-defined `weight`.
-- | 2. **Branch Nodes (AND / OR):**
-- |    - Combines children using a weighted average: `(ScoreA * WeightA + ScoreB * WeightB) / (WeightA + WeightB)`.
-- |    - **Operator Change Reset:** To preserve the dominance of logical branches 
-- |      (e.g., preventing `(A || B)` from crushing `C` in `(A || B) && C`), the builder checks for operator
-- |      transitions. If a child node comes from an opposing operator (`Or` inside `And`), its 
-- |      aggregate weight is artificially crushed to `1` against its siblings.
-- | 3. **Non-Scoring Nodes (Eq, Nothing):**
-- |    Nodes that do not implement text-search (e.g., strict equality) return `Nothing` for the score
-- |    and are entirely ignored during the propagation mathematics to avoid sinking the normalized mean.
buildWhere :: ∀ value. String -> Filter value -> Int -> Where
buildWhere schemaName filter_ = fold
  onByKey
  onByType
  onByValuePair
  onByValueMatches
  onTrue
  onFalse
  onAnd
  onOr
  onNot
  filter_
  where
  onByKey key idx =
    { sql: "key = $" <> show idx
    , values: [ writeImpl ((unwrap key).primary ??⇒ "") ]
    , score: Nothing
    , is: Leaf
    , froms: []
    }

  onByType _ _ =
    { sql: "true"
    , values: []
    , score: Nothing
    , is: Leaf
    , froms: []
    }

  onByValuePair pathParts op value idx =
    case op of
      Matches_ { weight, expectation } ->
        let
          searchString = case runExcept (readImpl value :: ExceptT _ _ String) of
            Right s -> s
            Left _ -> case runExcept (readImpl value :: ExceptT _ _ (Array String)) of
              Right arr -> joinWith " " arr
              Left _ -> unsafeCrashWith "Unsupported value type for search"
        in
          let
            normalizedForFrenchSearch = normalizeForFrenchTextSearch searchString
            normalizedForSearch = normalizeForTextSearch searchString
            sanitizedPathForIndexName = joinWith "_" pathParts
            colName = "value_" <> sanitizedPathForIndexName <> "_tsvector"
            rawPath = case length pathParts of
              1 -> "value->>'" <> joinWith "." pathParts <> "'"
              _ -> "value#>>'{" <> joinWith "," pathParts <> "}'"

            normPath = case length pathParts of
              1 -> "value->>'_" <> joinWith "." pathParts <> "'"
              _ ->
                let
                  mappedParts = pathParts # mapWithIndex \j p -> j == length pathParts - 1 ? ("_" <> p) ↔ p
                in
                  "value#>>'{" <> joinWith "," mappedParts <> "}'"

            -- IMPORTANT: Do not use parameter bindings (like $1) for column names or JSON paths!
            -- The PostgreSQL Query Planner computes the Execution Plan *before* binding variables
            -- (in order to cache and reuse the heavy plan computation for Prepared Statements).
            -- If it sees a dynamic path (e.g., value->>('_' || $1)), it cannot prove that the path
            -- matches any existing index expression. It will forcibly fallback to a full Sequential Scan.
            -- We MUST inline the literal column path directly into the SQL string to trigger Index Scans.

            idxFrench = idx
            idxNorm = idx + 1

            cteName = "fts_" <> show idxFrench

            -- IMPORTANT: The `OFFSET 0` is NOT a mistake, it is a crucial PostgreSQL Optimization Barrier.
            -- By default, Postgres 12+ aggressively flattens simple subqueries ("Subquery Pull-up"). If flattened, 
            -- the heavy `fts.expand_query` is injected into the Recheck Cond and executed iteratively for every 
            -- single matching row (taking ~5000ms).
            -- Injecting a pagination clause like `OFFSET 0` mathematically forbids Postgres from altering the query tree,
            -- forcing it to materialize the FTS AI expansion exactly ONCE in O(1) isolation (taking ~36ms).
            quickFlag = case expectation of
              SlowerSomethingBetterThanQuickNothing -> "false"
              QuickNothingBetterThanSlowerSomething -> "true"
            from = "(SELECT fts.expand_query('" <> schemaName <> "', ($" <> show idxFrench <> "::text), " <> quickFlag <> ") AS q OFFSET 0) " <> cteName

            fill sql =
              sql
                # replaceAll (Pattern "$colName") (Replacement colName)
                # replaceAll (Pattern "$cteName") (Replacement cteName)

            clause =
              fill
                """
                ($idxNorm::text IS NULL OR $idxNorm::text IS NOT NULL) AND
                $colName @@ $cteName.q
                AND ($colName <=> $cteName.q) <= 100.0
                """
                # replaceAll (Pattern "$idxNorm") (Replacement ("$" <> show idxNorm))

            weightBase = 1000.0

            weights =
              { eq: weightBase `pow` 2.0
              , ts: weightBase `pow` 1.0
              }

            weightsTotal =
              weights.eq
                + weights.ts

            lengthPenalty = case expectation of
              QuickNothingBetterThanSlowerSomething -> "sqrt(GREATEST(length($rawPath)::numeric, 1.0))"
              SlowerSomethingBetterThanQuickNothing -> "1.0"

            score' =
              fill
                ( """
                  $weight
                  * ($weightEq * (CASE WHEN $normPath = $idxNorm THEN 1.0 ELSE 0.0 END)
                    + $weightTs * (CASE WHEN $colName @@ $cteName.q THEN 1.0 / (1.0 + ($colName <=> $cteName.q)) ELSE 0.0 END) / $lengthPenalty
                  ) / $weightsTotal
                  """
                    # replaceAll (Pattern "$idxNorm") (Replacement ("$" <> show idxNorm))
                    # replaceAll (Pattern "$normPath") (Replacement normPath)
                    # replaceAll (Pattern "$lengthPenalty") (Replacement lengthPenalty)
                    # replaceAll (Pattern "$rawPath") (Replacement rawPath)
                    # replaceAll (Pattern "$weightEq") (Replacement $ show weights.eq)
                    # replaceAll (Pattern "$weightTs") (Replacement $ show weights.ts)
                    # replaceAll (Pattern "$weightsTotal") (Replacement $ show weightsTotal)
                    # replaceAll (Pattern "$weight") (Replacement $ show weight)
                )

          in
            { sql: clause
            , values: [ writeImpl normalizedForFrenchSearch, writeImpl normalizedForSearch ]
            , score: Just { sql: score', weight }
            , is: Leaf
            , froms: [ from ]
            }

      StrictlyEquals_ ->
        let
          path = joinWith "." pathParts
          sqlPath = case length pathParts of
            1 -> "->>'" <> path <> "'"
            _ -> "#>>'{" <> joinWith "," pathParts <> "}'"
        in
          { sql: "value" <> sqlPath <> " = $" <> show idx
          , values: [ value ]
          , score: Nothing
          , is: Leaf
          , froms: []
          }

      GreaterThan_ ->
        let
          path = joinWith "." pathParts
          sqlPath = case length pathParts of
            1 -> "->'" <> path <> "'"
            _ -> "#>'{" <> joinWith "," pathParts <> "}'"
        in
          { sql: "value" <> sqlPath <> " > ($" <> show idx <> "::jsonb)"
          , values: [ value ]
          , score: Nothing
          , is: Leaf
          , froms: []
          }

      LessThan_ ->
        let
          path = joinWith "." pathParts
          sqlPath = case length pathParts of
            1 -> "->'" <> path <> "'"
            _ -> "#>'{" <> joinWith "," pathParts <> "}'"
        in
          { sql: "value" <> sqlPath <> " < ($" <> show idx <> "::jsonb)"
          , values: [ value ]
          , score: Nothing
          , is: Leaf
          , froms: []
          }

      StrictlyNotEquals_ ->
        let
          path = joinWith "." pathParts
          sqlPath = case length pathParts of
            1 -> "->>'" <> path <> "'"
            _ -> "#>>'{" <> joinWith "," pathParts <> "}'"
        in
          { sql: "value" <> sqlPath <> " != $" <> show idx
          , values: [ value ]
          , score: Nothing
          , is: Leaf
          , froms: []
          }

      Exists_ ->
        let
          path = joinWith "." pathParts
          sqlPath = case length pathParts of
            1 -> "->>'" <> path <> "'"
            _ -> "#>>'{" <> joinWith "," pathParts <> "}'"
        in
          { sql: "value" <> sqlPath <> " IS NOT NULL"
          , values: []
          , score: Nothing
          , is: Leaf
          , froms: []
          }

      EqualsUpToNormalization_ ->
        let
          path = joinWith "." pathParts
          normSqlPath = case length pathParts of
            1 -> "->>'_" <> path <> "'"
            _ ->
              let
                mappedParts = pathParts # mapWithIndex \j p -> j == length pathParts - 1 ? ("_" <> p) ↔ p
              in
                "#>>'{" <> joinWith "," mappedParts <> "}'"
        in
          case runExcept (readImpl value :: ExceptT _ _ String) of
            Left _ -> unsafeCrashWith "Equality up to normalization requires a string value"
            Right str ->
              let
                normValue = normalizeForTextSearch str
              in
                { sql: "value" <> normSqlPath <> " = $" <> show idx
                , values: [ writeImpl normValue ]
                , score: Nothing
                , is: Leaf
                , froms: []
                }

      Contains_ ->
        let
          nestedJson =
            foldr
              (\k acc -> writeImpl (Object.singleton k acc))
              (writeImpl value)
              pathParts
        in
          { sql: "value @> $" <> show idx <> "::jsonb"
          , values: [ nestedJson ]
          , score: Nothing
          , is: Leaf
          , froms: []
          }

  onByValueMatches weight a b c d expectation searchString idx =
    let
      normalizedForFrenchSearch = normalizeForFrenchTextSearch searchString
      colName = "value_tsvector"

      idxFrench = idx
      cteName = "fts_" <> show idxFrench

      quickFlag = case expectation of
        SlowerSomethingBetterThanQuickNothing -> "false"
        QuickNothingBetterThanSlowerSomething -> "true"
      from =
        "(SELECT fts.expand_query('" <> schemaName <> "', $" <> show idxFrench <> ", " <> quickFlag <> ") AS q OFFSET 0) " <> cteName

      fill sql =
        sql
          # replaceAll (Pattern "$colName") (Replacement colName)
          # replaceAll (Pattern "$cteName") (Replacement cteName)

      clause =
        fill
          """
          $colName @@ $cteName.q
          AND ($colName <=> $cteName.q) <= 100.0
          """

      lengthPenalty = case expectation of
        QuickNothingBetterThanSlowerSomething -> "sqrt(GREATEST(length($colName)::numeric, 1.0))"
        SlowerSomethingBetterThanQuickNothing -> "1.0"

      -- Normalize weights to preserve their internal ratio while enforcing a maximum weight of 1.0.
      -- This ensures the raw score (x) scales predictably, preventing artificially large weights
      -- from causing the asymptotic squashing function (x / (1.0 + x)) to prematurely saturate at ~1.0.
      maxInW = max a (max b (max c d))
      maxInW' = maxInW == 0.0 ? 1.0 ↔ maxInW
      normA = a / maxInW'
      normB = b / maxInW'
      normC = c / maxInW'
      normD = d / maxInW'

      -- The raw score (x) combines term frequency (ts_rank) with a spatial distance modifier (<=>)
      -- from the RUM index, and applies a text length penalty. It is unbounded and can exceed 1.0.
      x = "((CASE WHEN $colName @@ $cteName.q THEN (ts_rank(ARRAY[$inWeightD, $inWeightC, $inWeightB, $inWeightA], $colName, $cteName.q) * (1.0 / (1.0 + ($colName <=> $cteName.q)))) ELSE 0.0 END) / $lengthPenalty)"

      score' =
        fill
          ( "$nodeWeight * $xFormula / (1.0 + $xFormula)"
              # replaceAll (Pattern "$xFormula") (Replacement x)
              # replaceAll (Pattern "$nodeWeight") (Replacement $ show weight)
              # replaceAll (Pattern "$lengthPenalty") (Replacement lengthPenalty)
              # replaceAll (Pattern "$inWeightA") (Replacement $ show normA)
              # replaceAll (Pattern "$inWeightB") (Replacement $ show normB)
              # replaceAll (Pattern "$inWeightC") (Replacement $ show normC)
              # replaceAll (Pattern "$inWeightD") (Replacement $ show normD)
          )

    in
      { sql: clause
      , values: [ writeImpl normalizedForFrenchSearch ]
      , score: Just { sql: score', weight }
      , is: Leaf
      , froms: [ from ]
      }

  onTrue _ _ = { sql: "true", values: [], score: Nothing, is: Leaf, froms: [] }
  onFalse _ _ = { sql: "false", values: [], score: Nothing, is: Leaf, froms: [] }

  onAnd f g idx =
    let
      x = f idx
      y = g (idx + length x.values)
    in
      { sql: "(" <> x.sql <> " AND " <> y.sql <> ")"
      , values: x.values <> y.values
      , score: case x.score, y.score of
          Just o1, Just o2 ->
            let
              w1 = if x.is == Or then 1.0 else o1.weight
              w2 = if y.is == Or then 1.0 else o2.weight
            in
              Just
                { sql: "((" <> o1.sql <> ") / " <> show o1.weight <> " * " <> show w1 <> " + (" <> o2.sql <> ") / " <> show o2.weight <> " * " <> show w2 <> ")"
                , weight: w1 + w2
                }
          Just o, Nothing ->
            let
              w = if x.is == Or then 1.0 else o.weight
            in
              Just { sql: "((" <> o.sql <> ") / " <> show o.weight <> " * " <> show w <> ")", weight: w }
          Nothing, Just o ->
            let
              w = if y.is == Or then 1.0 else o.weight
            in
              Just { sql: "((" <> o.sql <> ") / " <> show o.weight <> " * " <> show w <> ")", weight: w }
          _, _ -> Nothing
      , is: case x.score, y.score of
          Nothing, Nothing -> Leaf
          Just _, Nothing -> x.is
          Nothing, Just _ -> y.is
          Just _, Just _ -> And
      , froms: x.froms <> y.froms
      }

  onOr f g idx =
    let
      x = f idx
      y = g (idx + length x.values)
    in
      { sql: "(" <> x.sql <> " OR " <> y.sql <> ")"
      , values: x.values <> y.values
      , score: case x.score, y.score of
          Just o1, Just o2 ->
            let
              w1 = if x.is == And then 1.0 else o1.weight
              w2 = if y.is == And then 1.0 else o2.weight
            in
              Just
                { sql: "((" <> o1.sql <> ") / " <> show o1.weight <> " * " <> show w1 <> " + (" <> o2.sql <> ") / " <> show o2.weight <> " * " <> show w2 <> ")"
                , weight: w1 + w2
                }
          Just o, Nothing ->
            let
              w = if x.is == And then 1.0 else o.weight
            in
              Just { sql: "((" <> o.sql <> ") / " <> show o.weight <> " * " <> show w <> ")", weight: w }
          Nothing, Just o ->
            let
              w = if y.is == And then 1.0 else o.weight
            in
              Just { sql: "((" <> o.sql <> ") / " <> show o.weight <> " * " <> show w <> ")", weight: w }
          _, _ -> Nothing
      , is: case x.score, y.score of
          Nothing, Nothing -> Leaf
          Just _, Nothing -> x.is
          Nothing, Just _ -> y.is
          Just _, Just _ -> Or
      , froms: x.froms <> y.froms
      }

  onNot f idx =
    let
      x = f idx
    in
      { sql: "NOT (" <> x.sql <> ")"
      , values: x.values
      , score: Nothing
      , is: Leaf
      , froms: x.froms
      }
