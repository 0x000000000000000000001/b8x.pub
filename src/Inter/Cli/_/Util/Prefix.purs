module Inter.Cli.Util.Prefix where

import Proem

import Effect.Console as Console
import Inter.Cli.Util.Input as Input
import Run as RunM
import Run.Reader (Reader, askAt, runReaderAt, localAt)
import Type.Row (type (+))
import Data.String (split, joinWith) as String
import Data.String.Pattern (Pattern(..))
import Util.Type.String.Cli as Util.Type.String.Cli

type READER_CLI_PREFIX fx = (readerCliPrefix :: Reader String | fx)

readerCliPrefix' = π :: Π "readerCliPrefix"

runCliPrefixReader :: ∀ fx a. String -> RunM.Run (READER_CLI_PREFIX + fx) a -> RunM.Run fx a
runCliPrefixReader = runReaderAt readerCliPrefix'

askCliPrefix :: ∀ fx. RunM.Run (READER_CLI_PREFIX + fx) String
askCliPrefix = askAt readerCliPrefix'

localCliPrefix :: ∀ fx a. (String -> String) -> RunM.Run (READER_CLI_PREFIX + fx) a -> RunM.Run (READER_CLI_PREFIX + fx) a
localCliPrefix = localAt readerCliPrefix'

log :: ∀ fx. String -> RunM.Run (READER_CLI_PREFIX + RunM.EFFECT + fx) Ɩ
log msg = do
  prefix <- askCliPrefix
  let prefixedMsg = prefix <> String.joinWith ("\n" <> prefix) (String.split (Pattern "\n") msg)
  ʌ $ Console.log prefixedMsg

ask :: ∀ fx. String -> RunM.Run (READER_CLI_PREFIX + RunM.AFF + RunM.EFFECT + fx) String
ask promptText = do
  prefix <- askCliPrefix
  Input.ask (prefix <> promptText)

askMultiline :: ∀ fx. String -> RunM.Run (READER_CLI_PREFIX + RunM.AFF + RunM.EFFECT + fx) String
askMultiline promptText = do
  prefix <- askCliPrefix
  Input.askMultiline (prefix <> promptText)

askBoolean :: ∀ fx. String -> Boolean -> RunM.Run (READER_CLI_PREFIX + RunM.AFF + RunM.EFFECT + fx) Boolean
askBoolean promptText defaultVal = loop
  where
  loop = do
    let defaultStr = if defaultVal then "yes" else "no"
    yn <- ask (promptText <> " (default: " <> defaultStr <> ")")
    if Util.Type.String.Cli.isYes yn defaultVal then η true
    else if Util.Type.String.Cli.isNo yn (not defaultVal) then η false
    else do
      log "Please answer 'yes' or 'no'."
      loop
