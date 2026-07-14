module Util.Log.Warn
  (warn
  , warnAfterNewline
  , warnColor
  , warnColorize
  , warnEmoji
  , warnPrefixed
  , warnShort
  , warnShortAfterNewline
  , warnShortShow
  , warnShortShowAfterNewline
  , warnShow
  , warnShowAfterNewline
  ) where

import Proem

import Ansi.Codes (Color(..))
import Effect.Class (class MonadEffect)
import Effect.Console as Console
import Util.Log.Log (colorize, newline, prefixed)

warnColor :: Color
warnColor = Yellow

warnColorize :: String -> String
warnColorize = colorize warnColor

warn :: ∀ m. MonadEffect m => String -> m Ɩ
warn = ʌ ◁ Console.log ◁ (\m -> warnPrefixed m false false)

warnAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
warnAfterNewline msg = newline *> warn msg

warnShort :: ∀ m. MonadEffect m => String -> m Ɩ
warnShort = ʌ ◁ Console.log ◁ (\m -> warnPrefixed m true false)

warnShortAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
warnShortAfterNewline msg = newline *> warnShort msg

warnShortShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
warnShortShowAfterNewline = warnShortAfterNewline ◁ show

warnShortShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
warnShortShow = warnShort ◁ show

warnShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
warnShow = warn ◁ show

warnShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
warnShowAfterNewline = warnAfterNewline ◁ show

warnEmoji :: String
warnEmoji = "⚠️ "

warnPrefixed :: String -> Boolean -> Boolean -> String
warnPrefixed msg short colorize = prefixed "warn" warnColor warnEmoji msg short colorize