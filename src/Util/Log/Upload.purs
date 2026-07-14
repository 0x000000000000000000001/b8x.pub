module Util.Log.Upload
  (upload
  , uploadAfterNewline
  , uploadColor
  , uploadColorize
  , uploadEmoji
  , uploadPrefixed
  , uploadShort
  , uploadShortAfterNewline
  , uploadShortShow
  , uploadShortShowAfterNewline
  , uploadShow
  , uploadShowAfterNewline
  ) where

import Proem

import Ansi.Codes (Color(..))
import Util.Log.Log (colorize, newline, prefixed)
import Effect.Class (class MonadEffect)
import Effect.Console as Console

uploadColor :: Color
uploadColor = Cyan

uploadColorize :: String -> String
uploadColorize = colorize uploadColor

upload :: ∀ m. MonadEffect m => String -> m Ɩ
upload = ʌ ◁ Console.log ◁ (\m -> uploadPrefixed m false false)

uploadAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
uploadAfterNewline msg = newline *> upload msg

uploadShort :: ∀ m. MonadEffect m => String -> m Ɩ
uploadShort = ʌ ◁ Console.log ◁ (\m -> uploadPrefixed m true false)

uploadShortAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
uploadShortAfterNewline msg = newline *> uploadShort msg

uploadShortShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
uploadShortShowAfterNewline = uploadShortAfterNewline ◁ show

uploadShortShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
uploadShortShow = uploadShort ◁ show

uploadShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
uploadShow = upload ◁ show

uploadShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
uploadShowAfterNewline = uploadAfterNewline ◁ show

uploadEmoji :: String
uploadEmoji = "⬆️ "

uploadPrefixed :: String -> Boolean -> Boolean -> String
uploadPrefixed msg short colorize = prefixed "upload" uploadColor uploadEmoji msg short colorize