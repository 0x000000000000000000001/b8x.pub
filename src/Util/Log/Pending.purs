module Util.Log.Pending
  (pending
  , pendingAfterNewline
  , pendingColor
  , pendingColorize
  , pendingEmoji
  , pendingPrefixed
  , pendingShort
  , pendingShortAfterNewline
  , pendingShortShow
  , pendingShortShowAfterNewline
  , pendingShow
  , pendingShowAfterNewline
  ) where

import Proem

import Ansi.Codes (Color(..))
import Util.Log.Log (colorize, newline, prefixed)
import Effect.Class (class MonadEffect)
import Effect.Console as Console

pendingColor :: Color
pendingColor = BrightBlack

pendingColorize :: String -> String
pendingColorize = colorize pendingColor

pending :: ∀ m. MonadEffect m => String -> m Ɩ
pending = ʌ ◁ Console.log ◁ (\m -> pendingPrefixed m false false)

pendingAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
pendingAfterNewline msg = newline *> pending msg

pendingShort :: ∀ m. MonadEffect m => String -> m Ɩ
pendingShort = ʌ ◁ Console.log ◁ (\m -> pendingPrefixed m true false)

pendingShortAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
pendingShortAfterNewline msg = newline *> pendingShort msg

pendingShortShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
pendingShortShowAfterNewline = pendingShortAfterNewline ◁ show

pendingShortShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
pendingShortShow = pendingShort ◁ show

pendingShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
pendingShow = pending ◁ show

pendingShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
pendingShowAfterNewline = pendingAfterNewline ◁ show

pendingEmoji :: String
pendingEmoji = "⏳"

pendingPrefixed :: String -> Boolean -> Boolean -> String
pendingPrefixed msg short colorize = prefixed "pending" pendingColor pendingEmoji msg short colorize
