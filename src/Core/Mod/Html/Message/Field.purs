module Core.Mod.Html.Message.Field
  (defaultHtmlSanitize
  ) where

import Proem
import Control.Monad.Except as Control.Monad.Except

import Core.Message.Field.Field (Sanitized(..))
import Foreign (Foreign)
import Foreign as Foreign
import Yoga.JSON (readImpl)
import Data.Either (Either(..))
import Core.Mod.Html.Html (isEmpty)

defaultHtmlSanitize :: ∀ a. Sanitized a -> Foreign -> Sanitized a
defaultHtmlSanitize fallback json =
  if Foreign.isNull json then fallback
  else case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Intact
    Right str -> isEmpty str ? fallback ↔ Intact
