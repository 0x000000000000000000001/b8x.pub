module Util.Log.Error
  (error
  , errorAfterNewline
  , errorColor
  , errorColorize
  , errorEmoji
  , errorPrefixed
  , errorShort
  , errorShortAfterNewline
  , errorShortShow
  , errorShortShowAfterNewline
  , errorShow
  , errorShowAfterNewline
  ) where

import Proem

import Ansi.Codes (Color(..))
import Util.Log.Log (colorize, newline, prefixed)
import Effect.Class (class MonadEffect)
import Effect.Console as Console

errorColor :: Color
errorColor = Red

errorColorize :: String -> String
errorColorize = colorize errorColor

error :: ∀ m. MonadEffect m => String -> m Ɩ
error = ʌ ◁ Console.log ◁ (\m -> errorPrefixed m false false)

errorAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
errorAfterNewline msg = newline *> error msg

errorShort :: ∀ m. MonadEffect m => String -> m Ɩ
errorShort = ʌ ◁ Console.log ◁ (\m -> errorPrefixed m true false)

errorShortAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
errorShortAfterNewline msg = newline *> errorShort msg

errorShortShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
errorShortShowAfterNewline = errorShortAfterNewline ◁ show

errorShortShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
errorShortShow = errorShort ◁ show

errorShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
errorShow = error ◁ show

errorShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
errorShowAfterNewline = errorAfterNewline ◁ show

errorEmoji :: String
errorEmoji = "❌"

errorPrefixed :: String -> Boolean -> Boolean -> String
errorPrefixed msg short colorize = prefixed "error" errorColor errorEmoji msg short colorize
