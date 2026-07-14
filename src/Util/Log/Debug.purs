module Util.Log.Debug
  (debug
  , debugAfterNewline
  , debugColor
  , debugColorize
  , debugEmoji
  , debugPrefixed
  , debugShort
  , debugShortAfterNewline
  , debugShortShow
  , debugShortShowAfterNewline
  , debugShow
  , debugShowAfterNewline
  ) where

import Proem

import Ansi.Codes (Color(..))
import Util.Log.Log (colorize, newline, prefixed)
import Effect.Class (class MonadEffect)
import Effect.Console as Console

debugColor :: Color
debugColor = Magenta

debugColorize :: String -> String
debugColorize = colorize debugColor

debug :: ∀ m. MonadEffect m => String -> m Ɩ
debug = ʌ ◁ Console.log ◁ (\m -> debugPrefixed m false false)

debugAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
debugAfterNewline msg = newline *> debug msg

debugShort :: ∀ m. MonadEffect m => String -> m Ɩ
debugShort = ʌ ◁ Console.log ◁ (\m -> debugPrefixed m true false)

debugShortAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
debugShortAfterNewline msg = newline *> debugShort msg

debugShortShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
debugShortShowAfterNewline = debugShortAfterNewline ◁ show

debugShortShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
debugShortShow = debugShort ◁ show

debugShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
debugShow = debug ◁ show

debugShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
debugShowAfterNewline = debugAfterNewline ◁ show

debugEmoji :: String
debugEmoji = "🪲 "

debugPrefixed :: String -> Boolean -> Boolean -> String
debugPrefixed msg short colorize = prefixed "debug" debugColor debugEmoji msg short colorize