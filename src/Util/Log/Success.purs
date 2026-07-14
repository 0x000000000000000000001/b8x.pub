module Util.Log.Success
  (success
  , successAfterNewline
  , successColor
  , successColorize
  , successEmoji
  , successPrefixed
  , successShort
  , successShortAfterNewline
  , successShortShow
  , successShortShowAfterNewline
  , successShow
  , successShowAfterNewline
  ) where

import Proem

import Ansi.Codes (Color(..))
import Util.Log.Log (colorize, newline, prefixed)
import Effect.Class (class MonadEffect)
import Effect.Console as Console

successColor :: Color
successColor = Green

successColorize :: String -> String
successColorize = colorize successColor

success :: ∀ m. MonadEffect m => String -> m Ɩ
success = ʌ ◁ Console.log ◁ (\m -> successPrefixed m false false)

successAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
successAfterNewline msg = newline *> success msg

successShort :: ∀ m. MonadEffect m => String -> m Ɩ
successShort = ʌ ◁ Console.log ◁ (\m -> successPrefixed m true false)

successShortAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
successShortAfterNewline msg = newline *> successShort msg

successShortShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
successShortShowAfterNewline = successShortAfterNewline ◁ show

successShortShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
successShortShow = successShort ◁ show

successShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
successShow = success ◁ show

successShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
successShowAfterNewline = successAfterNewline ◁ show

successEmoji :: String
successEmoji = "✅"

successPrefixed :: String -> Boolean -> Boolean -> String
successPrefixed msg short colorize = prefixed "success" successColor successEmoji msg short colorize