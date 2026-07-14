module Util.Log.Info
  (info
  , infoAfterNewline
  , infoColor
  , infoColorize
  , infoEmoji
  , infoPrefixed
  , infoShort
  , infoShortAfterNewline
  , infoShortShow
  , infoShortShowAfterNewline
  , infoShow
  , infoShowAfterNewline
  ) where

import Proem

import Ansi.Codes (Color(..))
import Util.Log.Log (colorize, newline, prefixed)
import Effect.Class (class MonadEffect)
import Effect.Console as Console

infoColor :: Color
infoColor = Blue

infoColorize :: String -> String
infoColorize = colorize infoColor

info :: ∀ m. MonadEffect m => String -> m Ɩ
info = ʌ ◁ Console.log ◁ (\m -> infoPrefixed m false false)

infoAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
infoAfterNewline msg = newline *> info msg

infoShort :: ∀ m. MonadEffect m => String -> m Ɩ
infoShort = ʌ ◁ Console.log ◁ (\m -> infoPrefixed m true false)

infoShortAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
infoShortAfterNewline msg = newline *> infoShort msg

infoShortShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
infoShortShowAfterNewline = infoShortAfterNewline ◁ show

infoShortShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
infoShortShow = infoShort ◁ show

infoShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
infoShow = info ◁ show

infoShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
infoShowAfterNewline = infoAfterNewline ◁ show

infoEmoji :: String
infoEmoji = "ℹ️ "

infoPrefixed :: String -> Boolean -> Boolean -> String
infoPrefixed msg short colorize = prefixed "info" infoColor infoEmoji msg short colorize