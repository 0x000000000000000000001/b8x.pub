module Util.Log.Download
  (download
  , downloadAfterNewline
  , downloadColor
  , downloadColorize
  , downloadEmoji
  , downloadPrefixed
  , downloadShort
  , downloadShortAfterNewline
  , downloadShortShow
  , downloadShortShowAfterNewline
  , downloadShow
  , downloadShowAfterNewline
  ) where

import Proem

import Ansi.Codes (Color(..))
import Util.Log.Log (colorize, newline, prefixed)
import Effect.Class (class MonadEffect)
import Effect.Console as Console

downloadColor :: Color
downloadColor = Cyan

downloadColorize :: String -> String
downloadColorize = colorize downloadColor

download :: ∀ m. MonadEffect m => String -> m Ɩ
download = ʌ ◁ Console.log ◁ (\m -> downloadPrefixed m false false)

downloadAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
downloadAfterNewline msg = newline *> download msg

downloadShort :: ∀ m. MonadEffect m => String -> m Ɩ
downloadShort = ʌ ◁ Console.log ◁ (\m -> downloadPrefixed m true false)

downloadShortAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
downloadShortAfterNewline msg = newline *> downloadShort msg

downloadShortShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
downloadShortShowAfterNewline = downloadShortAfterNewline ◁ show

downloadShortShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
downloadShortShow = downloadShort ◁ show

downloadShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
downloadShow = download ◁ show

downloadShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
downloadShowAfterNewline = downloadAfterNewline ◁ show

downloadEmoji :: String
downloadEmoji = "⬇️ "

downloadPrefixed :: String -> Boolean -> Boolean -> String
downloadPrefixed msg short colorize = prefixed "download" downloadColor downloadEmoji msg short colorize