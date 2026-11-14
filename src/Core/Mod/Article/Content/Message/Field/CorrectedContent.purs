module Core.Mod.Article.Content.Message.Field.CorrectedContent where

import Proem
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Control.Monad.Except (runExcept)

import Core.Message.Field.Field (class IsField, Sanitized(..), Presence(..), defaultShouldSanitizeInner)
import Core.Mod.Url.Url (Url)
import Core.Message.Command.Corrected (Corrected(AsIs))
import Core.Message.Command.Corrected (Corrected(..)) as Util
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Newtype (class Newtype)

type CorrectedContent = Util.Corrected Url

newtype CorrectedContentField = CorrectedContentField CorrectedContent

description :: String
description = "Content URL (.docx file)"

instance IsField CorrectedContentField CorrectedContent () where
  name = "CorrectedContent"

  description = description

  presence = Optional (η AsIs) "No change"

  sanitize json = case runExcept (readImpl json) of
    Left _ -> Intact
    Right (url :: Url) -> Corrected (Util.Corrected url)

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype CorrectedContentField _
derive newtype instance ReadForeign CorrectedContentField
derive newtype instance WriteForeign CorrectedContentField
derive newtype instance Eq CorrectedContentField
derive newtype instance Show CorrectedContentField
