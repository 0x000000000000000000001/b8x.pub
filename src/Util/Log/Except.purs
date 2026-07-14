module Util.Log.Except
  (except
  , exceptAfterNewline
  , exceptColor
  , exceptColorize
  , exceptEmoji
  , exceptPrefixed
  , exceptShort
  , exceptShortAfterNewline
  , exceptShortShow
  , exceptShortShowAfterNewline
  , exceptShow
  , exceptShowAfterNewline
  ) where

import Proem

import Ansi.Codes (Color(..))
import Util.Log.Log (colorize, newline, prefixed)
import Effect.Class (class MonadEffect)
import Effect.Console as Console

exceptColor :: Color
exceptColor = Red

exceptColorize :: String -> String
exceptColorize = colorize exceptColor

except :: ∀ m. MonadEffect m => String -> m Ɩ
except = ʌ ◁ Console.log ◁ (\m -> exceptPrefixed m false false)

exceptAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
exceptAfterNewline msg = newline *> except msg

exceptShort :: ∀ m. MonadEffect m => String -> m Ɩ
exceptShort = ʌ ◁ Console.log ◁ (\m -> exceptPrefixed m true false)

exceptShortAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
exceptShortAfterNewline msg = newline *> exceptShort msg

exceptShortShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
exceptShortShowAfterNewline = exceptShortAfterNewline ◁ show

exceptShortShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
exceptShortShow = exceptShort ◁ show

exceptShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
exceptShow = except ◁ show

exceptShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
exceptShowAfterNewline = exceptAfterNewline ◁ show

exceptEmoji :: String
exceptEmoji = "❌"

exceptPrefixed :: String -> Boolean -> Boolean -> String
exceptPrefixed msg short colorize = prefixed "except" exceptColor exceptEmoji msg short colorize