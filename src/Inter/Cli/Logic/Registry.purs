-- Keep the large alias dictionary shared during backend optimization.
-- @inline Inter.Cli.Logic.Registry.buildAliasDictCons never
module Inter.Cli.Logic.Registry where

import Util.Foreign.Native as Util.Foreign.Native
import Foreign as Foreign
import Foreign.Index (readProp) as ForeignIndex
import Data.Nullable as Data.Nullable

import Proem

import Control.Alternative ((<|>))
import Core.Message.Command.Command (class IsCommand)
import Core.Message.Command.Command as Command
import Core.Message.Command.Handle.Handle (handleCommand)
import Core.Message.Command.Index (CommandRow, CommandAliasRow)
import Core.Message.Command.Make (makeCommand)
import Core.Message.Field.Field (class IsField, Presence(..), cli, presence)

import Core.Message.Field.Payload (class MakePayload)

import Core.Message.Query.Index (QueryRow)
import Core.Message.Query.Make (makeQuery)
import Core.Message.MakeMessageM (liftMakeMessageM)
import Core.Message.Query.Query (class IsQuery)
import Core.Message.Query.Query as Query
import Core.Message.Queue (queueCommand_)
import Foreign (Foreign)
import Data.Array as Array
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)
import Control.Monad.Except (runExcept)
import Data.Either (either, hush)
import Data.CatQueue as CatQueue
import Data.Maybe (Maybe(..), optional, fromMaybe)
import Data.Int as Int
import Type.Proxy (Proxy(..))
import Data.Newtype (wrap)
import Data.String (toLower, replaceAll, joinWith, contains)
import Data.String.Pattern (Pattern(..), Replacement(..))
import Data.Symbol (class IsSymbol, reflectSymbol)
import Data.Variant (inj)
import Foreign.Object (Object)
import Foreign.Object as Object
import Core.Mod.Message.Field.Inter.Cli.CustomActs (class HasCustomCliAct, getCustomCliAct)
import Core.Mod.Message.Field.Inter.Cli.Type (BaseCliFx, CustomCliActResult(..))
import Inter.Cli.Logic.LogicM (LogicM)
import Inter.Cli.Util.Prefix as Prefix
import Options.Applicative (ParserInfo, header, help, info, long, metavar, strOption, progDesc)
import Options.Applicative as OptAp
import Prim.Row as Row
import Prim.RowList (class RowToList, Cons, Nil, RowList)
import Prim.RowList as RowList
import Run (Run)
import Util.Type.Row.Registry (class RegistryBuilder, buildRegistry, buildRegistryFromRowList)
import Util.Type.String.Cli (isYes)
import Util.Type.String.String (caseToKebab, lowerCaseFirst)
import Util.Type.Type (class Reflect, reflectName)

type Actions =
  { askQueue :: Maybe (LogicM Ɩ)
  , askHandle :: LogicM Foreign
  , name :: String
  , isCommand :: Boolean
  }

type ActionsParserInfo = ParserInfo Actions

type AliasEntry = { name :: String, info :: ActionsParserInfo }

type RegistryEntry = { info :: ActionsParserInfo, aliases :: Array AliasEntry, askHandleWithOpts :: Object Foreign -> LogicM Foreign }

registry :: Object RegistryEntry
registry =
  (buildRegistry @LogicCommands @CommandRow)
    `Object.union`
      (buildRegistry @LogicQueries @QueryRow)

class BuildAliasDict (rowList :: RowList Type) where
  buildAliasDictFromRowList :: Object (Array String)

instance BuildAliasDict Nil where
  buildAliasDictFromRowList = Object.empty

instance buildAliasDictCons ::
  ( IsSymbol aliasName
  , Reflect cmd
  , BuildAliasDict tail
  ) =>
  BuildAliasDict (Cons aliasName cmd tail) where
  buildAliasDictFromRowList =
    let
      tailDict = buildAliasDictFromRowList @tail
      cmdName = reflectName @cmd
      aliasName = reflectSymbol (Proxy :: Proxy aliasName)
      existing = fromMaybe [] (Object.lookup cmdName tailDict)
    in
      Object.insert cmdName (Array.snoc existing aliasName) tailDict

buildAliasDict :: ∀ @r rl. RowToList r rl => BuildAliasDict rl => Object (Array String)
buildAliasDict = buildAliasDictFromRowList @rl

class ToCliOutput a where
  toCliOutput :: a -> Foreign

instance ToCliOutput Unit where
  toCliOutput _ = Foreign.unsafeToForeign (Data.Nullable.null :: Data.Nullable.Nullable Unit)
else instance WriteForeign a => ToCliOutput a where
  toCliOutput = writeImpl

-- Command Registry Builder

data LogicCommands

instance
  ( IsSymbol cmdName
  , IsCommand cmd state fields payload a
  , Reflect cmd
  , ToCliOutput a
  , Ask fields
  , Parser fields
  , RegistryBuilder LogicCommands tail RegistryEntry
  , Row.Cons cmdName cmd commandRowTail CommandRow
  , MakePayload fields payload
  ) =>
  RegistryBuilder LogicCommands (Cons cmdName cmd tail) RegistryEntry where
  buildRegistryFromRowList =
    let
      tailRegistry = buildRegistryFromRowList @LogicCommands @tail
      cmdName = reflectName @cmd

      parser' = parser @fields

      askHandleWithOpts opts = ask @fields opts >>= (makeCommand @cmd ▷ liftMakeMessageM) >>= handleCommand @cmd true <#> toCliOutput

      buildActions opts =
        { askQueue: Just $ ask @fields opts >>= (makeCommand @cmd ▷ liftMakeMessageM) >>= (inj (π :: Π cmdName) ▷ wrap ▷ queueCommand_)
        , askHandle: askHandleWithOpts opts
        , name: reflectName @cmd
        , isCommand: true
        }

      aliasesObj = buildAliasDict @CommandAliasRow
      aliasesForCmd = fromMaybe [] (Object.lookup cmdName aliasesObj)

      aliasInfo = info (buildActions <$> parser') (progDesc "")
      aliases = map (\aliasName -> { name: aliasName, info: aliasInfo }) aliasesForCmd

      info' = info (buildActions <$> parser') (progDesc (Command.description @cmd) <> header (Command.description @cmd))
    in
      Object.insert cmdName { info: info', aliases, askHandleWithOpts } tailRegistry

-- Query Registry Builder

data LogicQueries

instance
  ( IsSymbol queryName
  , IsQuery query state fields payload a
  , Reflect query
  , ReadForeign a
  , WriteForeign a
  , ToCliOutput a
  , Ask fields
  , Parser fields
  , RegistryBuilder LogicQueries tail RegistryEntry
  , Row.Cons queryName query queryRowTail QueryRow
  , MakePayload fields payload
  ) =>
  RegistryBuilder LogicQueries (Cons queryName query tail) RegistryEntry where
  buildRegistryFromRowList =
    let
      tailRegistry = buildRegistryFromRowList @LogicQueries @tail
      queryName = reflectName @query

      parser' = parser @fields

      askHandleWithOpts opts = ask @fields opts >>= (makeQuery @query ▷ liftMakeMessageM) >>= Query.handleWithCache <#> toCliOutput

      buildActions opts =
        { askQueue: Nothing
        , askHandle: askHandleWithOpts opts
        , name: reflectName @query
        , isCommand: false
        }

      info' = info (buildActions <$> parser') (progDesc (Query.description @query) <> header (Query.description @query))
    in
      Object.insert queryName { info: info', aliases: [], askHandleWithOpts } tailRegistry

-- Parser

class Parser (fields :: Row Type) where
  parser :: OptAp.Parser (Object Foreign)

instance
  ( RowToList fields fieldsRowList
  , ParserFromRowList fieldsRowList fields
  ) =>
  Parser fields where
  parser = parserFromRowList @fieldsRowList @fields ""

class ParserFromRowList (fieldsRowList :: RowList Type) (fields :: Row Type) where
  parserFromRowList :: String -> OptAp.Parser (Object Foreign)

instance ParserFromRowList Nil fields where
  parserFromRowList _ = η Object.empty

instance
  ( IsSymbol key
  , IsField field a children
  , RowToList children childrenList
  , ParserForField field a childrenList
  , ParserFromRowList fieldsTail fields
  ) =>
  ParserFromRowList (RowList.Cons key field fieldsTail) fields where
  parserFromRowList prefix =
    let
      keyStr = ᴠ @key
      head = parserForField @field @a @childrenList prefix keyStr
      tail = parserFromRowList @fieldsTail @fields prefix

      insert v obj = case v of
        Just parsedJson -> Object.insert keyStr parsedJson obj
        Nothing -> obj
    in
      insert <$> head <*> tail

class ParserForField (field :: Type) (a :: Type) (childrenList :: RowList Type) where
  parserForField :: String -> String -> OptAp.Parser (Maybe Foreign)

makeLeafParser
  :: ∀ @field a children
   . IsField field a children
  => String
  -> String
  -> OptAp.Parser (Maybe Foreign)
makeLeafParser prefix keyStr =
  let
    cli' = cli @field
    presence' = presence @field
    name' = prefix <> (keyStr # caseToKebab)

    optParser = optional $ strOption
      ( (long name')
          <> metavar "VALUE"
          <> help
            ( cli'.description
                <>
                  ( case presence' of
                      Optional _ defaultDescription -> " (default: " <> lowerCaseFirst defaultDescription <> ")"
                      Required -> ""
                  )
            )
      )
    valParser = map (\x -> map (\v -> either (κ $ writeImpl v) identity (Util.Foreign.Native.parseJSON v)) x) optParser
  in
    case presence' of
      Optional _ defaultDescription ->
        let
          cancelParser = OptAp.flag' (Just (Foreign.unsafeToForeign (Data.Nullable.null :: Data.Nullable.Nullable Unit))) (long ("skip-" <> name') <> help ("Skip " <> replaceAll (Pattern "-") (Replacement " ") name' <> " (default: " <> lowerCaseFirst defaultDescription <> ")"))
        in
          cancelParser <|> valParser
      Required -> valParser

instance
  ( IsField field (Array a) children
  , RowToList children childrenList
  ) =>
  ParserForField field (Array a) childrenList where
  parserForField = makeLeafParser @field

else instance
  ( IsField field a ()
  ) =>
  ParserForField field a Nil where
  parserForField = makeLeafParser @field

else instance
  ( IsField field a children
  , RowToList children (Cons k v tail)
  , ParserFromRowList (Cons k v tail) children
  ) =>
  ParserForField field a (Cons k v tail) where
  parserForField prefix keyStr =
    let
      name' = prefix <> (keyStr # caseToKebab) <> "-"
      flagName = prefix <> (keyStr # caseToKebab)
      presence' = presence @field

      childrenParser =
        parserFromRowList @(Cons k v tail) @children name'
          <#> (\o -> Object.isEmpty o ? Nothing ↔ Just (writeImpl o))
    in
      case presence' of
        Optional _ defaultDescription ->
          let
            cancelParser = OptAp.flag' (Just (Foreign.unsafeToForeign (Data.Nullable.null :: Data.Nullable.Nullable Unit))) (long ("skip-" <> flagName) <> help ("Skip " <> replaceAll (Pattern "-") (Replacement " ") flagName <> " (default: " <> lowerCaseFirst defaultDescription <> ")"))
          in
            cancelParser <|> childrenParser
        Required -> childrenParser

-- Ask

class Ask (fields :: Row Type) where
  ask :: Object Foreign -> LogicM (Object Foreign)

instance
  ( RowToList fields fieldsList
  , AskFromRowList fieldsList fields
  ) =>
  Ask fields where
  ask opt = askFromRowList @fieldsList @fields "" "" opt

class AskFromRowList (fieldsList :: RowList Type) (fields :: Row Type) where
  askFromRowList :: String -> String -> Object Foreign -> LogicM (Object Foreign)

instance AskFromRowList Nil fields where
  askFromRowList _ _ _ = η Object.empty

instance
  ( IsSymbol key
  , IsField field a children
  , RowToList children childrenList
  , AskForField field a childrenList
  , AskFromRowList fieldsTail fields
  ) =>
  AskFromRowList (RowList.Cons key field fieldsTail) fields where
  askFromRowList prefix labelPrefix optParsingObj = do
    let
      keyStr = ᴠ @key
      val' = Object.lookup keyStr optParsingObj

    when (prefix == "") do
      Prefix.log ""

    val <- askForField @field @a @childrenList prefix labelPrefix keyStr val'
    rest <- askFromRowList @fieldsTail @fields prefix labelPrefix optParsingObj

    η $ case val of
      Just v -> Object.insert keyStr v rest
      Nothing -> rest

class AskForField (field :: Type) (a :: Type) (childrenList :: RowList Type) where
  askForField :: String -> String -> String -> Maybe Foreign -> LogicM (Maybe Foreign)

handleOptVal
  :: Maybe Foreign
  -> LogicM (Maybe Foreign)
  -> LogicM (Maybe Foreign)
handleOptVal optVal onNothing =
  case optVal of
    Just jsonVal -> do
      if Foreign.isUndefined jsonVal || Foreign.isNull jsonVal then η Nothing
      else η (Just jsonVal)
    Nothing -> onNothing

askTriggeredCommand :: String -> Foreign -> LogicM String
askTriggeredCommand cmdName optsJson = case Object.lookup cmdName registry of
  Just entry -> do
    let opts = (runExcept (readImpl optsJson) # hush) ??⇒ Object.empty
    resJson <- Prefix.localCliPrefix (\p -> p <> "│ ") (entry.askHandleWithOpts opts)
    η $ fromMaybe "" (hush (runExcept (ForeignIndex.readProp "id" resJson >>= Foreign.readString)))
  Nothing -> do
    Prefix.log $ "Command not found: " <> cmdName
    η ""

instance
  ( IsField field (Array a) ()
  , HasCustomCliAct field
  ) =>
  AskForField field (Array a) Nil where
  askForField _ labelPrefix _ optVal = handleOptVal optVal $ do
    let
      cli' = cli @field
      choicesStr = case cli'.choices of
        Just c -> " (choices: " <> joinWith ", " (Array.mapWithIndex (\i choice -> show i <> "/" <> choice) c) <> ")"
        Nothing -> ""
      askItem _ prompt = do
        let description = labelPrefix <> prompt <> " of " <> lowerCaseFirst cli'.description <> choicesStr
        let
          askLoop = do
            val <- case getCustomCliAct @field of
              Just act -> act prompt >>= case _ of
                UserInput str -> η str
                TriggerCommand cmdName opts -> askTriggeredCommand cmdName opts
              Nothing -> case cli'.multiline of
                true -> Prefix.askMultiline description
                false -> Prefix.ask description
            let 
              finalVal = case cli'.choices, Int.fromString val of
                Just c, Just idx -> fromMaybe val (Array.index c idx)
                _, _ -> val
            case cli'.choices of
              Just c ->
                if Array.elem finalVal c then η finalVal
                else do
                  Prefix.log "Invalid choice. Please select a valid option."
                  askLoop
              Nothing -> η finalVal
        finalVal <- askLoop
        η $ either (κ $ writeImpl finalVal) identity (Util.Foreign.Native.parseJSON finalVal)

    arr <- askListElements (labelPrefix <> cli'.description) askItem
    η $ Just (writeImpl arr)

else instance
  ( IsField field Boolean ()
  ) =>
  AskForField field Boolean Nil where
  askForField _ labelPrefix _ optVal = handleOptVal optVal $ do
    let
      cli' = cli @field
      presence' = presence @field
      defaultVal = case presence' of
        Optional _ defaultDescription -> isYes defaultDescription false
        Required -> false

    finalVal <- Prefix.askBoolean (labelPrefix <> cli'.description) defaultVal
    case presence' of
      Optional _ _ -> if finalVal == defaultVal then η Nothing else η $ Just $ writeImpl finalVal
      Required -> η $ Just $ writeImpl finalVal

else instance
  ( IsField field a ()
  , HasCustomCliAct field
  ) =>
  AskForField field a Nil where
  askForField _ labelPrefix _ optVal = handleOptVal optVal $ do
    let
      cli' = cli @field
      presence' = presence @field
      descSuffix = case presence' of
        Optional _ defaultDescription -> " (default: " <> lowerCaseFirst defaultDescription <> ")"
        Required -> ""
      choicesStr = case cli'.choices of
        Just c -> " (choices: " <> joinWith ", " (Array.mapWithIndex (\i choice -> show i <> "/" <> choice) c) <> ")"
        Nothing -> ""
      description = labelPrefix <> cli'.description <> choicesStr <> descSuffix

    let
      hasCustomAct = case getCustomCliAct @field of
        Nothing -> false
        Just _ -> true

    skipAct <- case presence', hasCustomAct of
      Optional _ _, true -> do
        b <- Prefix.askBoolean ("Do you want to provide the " <> lowerCaseFirst (labelPrefix <> cli'.description) <> "?") true
        η (not b)
      _, _ -> η false

    if skipAct then η Nothing
    else do
      let
        askLoop = do
          val <- case getCustomCliAct @field of
            Just act -> act "" >>= case _ of
              UserInput str -> η str
              TriggerCommand cmdName opts -> askTriggeredCommand cmdName opts
            Nothing -> case cli'.multiline of
              true -> Prefix.askMultiline description
              false -> Prefix.ask description
          let 
            finalVal = case cli'.choices, Int.fromString val of
              Just c, Just idx -> fromMaybe val (Array.index c idx)
              _, _ -> val
          case cli'.choices of
            Just c ->
              if Array.elem finalVal c then η finalVal
              else if finalVal == "" then η finalVal -- Let empty string pass through for optional check later
              else do
                Prefix.log "Invalid choice. Please select a valid option."
                askLoop
            Nothing -> η finalVal
      finalVal <- askLoop

      let isOptional = case presence' of
            Optional _ _ -> true
            Required -> false

      if finalVal == "" && isOptional then η Nothing
      else η $ Just $ either (κ $ writeImpl finalVal) identity (Util.Foreign.Native.parseJSON finalVal)

instance
  ( IsField field (Array a) children
  , RowToList children (Cons k v tail)
  , AskFromRowList (Cons k v tail) children
  ) =>
  AskForField field (Array a) (Cons k v tail) where
  askForField prefix labelPrefix keyStr optVal = handleOptVal optVal $ do
    let
      cli' = cli @field
      name' = prefix <> (keyStr # caseToKebab) <> "-"

      askItem _ prompt = do
        childrenObj <- askFromRowList @(Cons k v tail) @children (name' <> prompt <> "-") (labelPrefix <> "(" <> prompt <> " of " <> lowerCaseFirst cli'.description <> ") ") Object.empty
        η (writeImpl childrenObj)

    arr <- askListElements (labelPrefix <> cli'.description) askItem
    η $ Just (writeImpl arr)

else instance
  ( IsField field a children
  , RowToList children (Cons k v tail)
  , AskFromRowList (Cons k v tail) children
  ) =>
  AskForField field a (Cons k v tail) where
  askForField prefix labelPrefix keyStr optVal = do
    let
      name' = prefix <> (keyStr # caseToKebab) <> "-"
      description = (cli @field).description

    case optVal of
      Just jsonVal -> do
        if Foreign.isUndefined jsonVal || Foreign.isNull jsonVal then η Nothing
        else do
          let obj = (runExcept (readImpl jsonVal) # hush) ??⇒ Object.empty
          childrenObj <- askFromRowList @(Cons k v tail) @children name' labelPrefix obj
          η $ Just (writeImpl childrenObj)

      Nothing -> case presence @field of
        Required -> do
          childrenObj <- askFromRowList @(Cons k v tail) @children name' labelPrefix Object.empty
          η $ Just (writeImpl childrenObj)
        Optional _ _ -> do
          b <- Prefix.askBoolean ("Do you want to provide the " <> lowerCaseFirst (labelPrefix <> description) <> "?") true

          if not b then η Nothing
          else do
            childrenObj <- askFromRowList @(Cons k v tail) @children name' labelPrefix Object.empty
            η $ Just (writeImpl childrenObj)

askListElements :: ∀ fx. String -> (Int -> String -> Run (BaseCliFx fx) Foreign) -> Run (BaseCliFx fx) (Array Foreign)
askListElements description askItem = do
  let
    loop idx acc = do
      let
        isFirstElement = idx == 0
        verb = isFirstElement ? "fill" ↔ "expand"
        isLegacy = contains (Pattern "legacy") (toLower description)
        -- Once a first element has been provided, default to stopping the list.
        defaultVal = isFirstElement ? not isLegacy ↔ false

      b <- Prefix.askBoolean ("Do you want to " <> verb <> " the list of " <> lowerCaseFirst description <> "?") defaultVal

      if b then do
        let
          n = idx + 1
          r100 = n `mod` 100
          r10 = n `mod` 10
          prompt =
            if r100 >= 11 && r100 <= 13 then show n <> "th"
            else case r10 of
              1 -> show n <> "st"
              2 -> show n <> "nd"
              3 -> show n <> "rd"
              _ -> show n <> "th"

        item <- askItem idx prompt
        loop n (CatQueue.snoc acc item)
      else
        η $ Array.fromFoldable acc
  loop 0 CatQueue.empty
