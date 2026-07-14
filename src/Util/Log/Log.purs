module Util.Log.Log
  (carriageReturn
  , colorize
  , log
  , logAfterNewline
  , logShow
  , logShowAfterNewline
  , newline
  , prefixed
  , write
  ) where

import Proem

import Ansi.Codes (Color, EscapeCode(..), GraphicsParam(..), escapeCodeToString)
import Data.List.NonEmpty (singleton)
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Effect.Console as Console

colorize :: Color -> String -> String
colorize c s =
  escapeCodeToString (Graphics (singleton $ PForeground c))
    <> s
    <> escapeCodeToString (Graphics (singleton Reset))

carriageReturn :: String
carriageReturn = "\r"

foreign import _write :: String -> Effect Ɩ

write :: ∀ m. MonadEffect m => String -> m Ɩ
write str = ʌ $ _write str

log :: ∀ m. MonadEffect m => String -> m Ɩ
log = ʌ ◁ Console.log

logAfterNewline :: ∀ m. MonadEffect m => String -> m Ɩ
logAfterNewline msg = newline *> log msg

logShow :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
logShow = log ◁ show

logShowAfterNewline :: ∀ m a. MonadEffect m => Show a => a -> m Ɩ
logShowAfterNewline = logAfterNewline ◁ show

prefixed :: String -> Color -> String -> String -> Boolean -> Boolean -> String
prefixed prefix color emoji msg short colorize_ =
  emoji
    <> " "
    <> (short ? "" ↔ colorize color $ "[" <> prefix <> "] ")
    <> (colorize_ ? (colorize color msg) ↔ msg)

newline :: ∀ m. MonadEffect m => m Ɩ
newline = log ""
