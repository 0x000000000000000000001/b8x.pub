module Inter.Cli.Util.Input
  (ask
  , askMultiline
  ) where

import Proem

import Effect.Aff.Class (class MonadAff)
import Node.ReadLine (createInterface, question, close, output, terminal)
import Node.Process (stdin, stdout)
import Effect.Aff (makeAff, nonCanceler)
import Data.Either (Either(..))
import Data.Options ((:=))
import Effect.Console (log)
import Data.String (trim, joinWith)
import Data.String.CodeUnits (length, drop)
import Data.CatQueue as CatQueue
import Data.Array as Array

ask :: ∀ m. MonadAff m => String -> m String
ask promptText = ʌ' $ makeAff \callback -> do
  interface <- createInterface stdin (output := stdout <> terminal := true)

  let
    trimmed = trim promptText
    len = length trimmed
    suffix = if drop (len - 1) trimmed == "?" then " " else ": "

  question (promptText <> suffix)
    (\answer -> do
        close interface
        callback (Right answer)
    )
    interface

  η nonCanceler

askMultiline :: ∀ m. MonadAff m => String -> m String
askMultiline promptText = ʌ' $ makeAff \callback -> do
  interface <- createInterface stdin (output := stdout <> terminal := true)

  log $ promptText <> " (multi-line, end with a dot '.' on a new line): "

  let
    go lines = question ""
      (\line -> do
          if trim line == "." then do
            close interface
            callback $ Right $ joinWith "\n" (Array.fromFoldable lines)
          else
            go $ CatQueue.snoc lines line
      )
      interface

  go CatQueue.empty

  η nonCanceler
