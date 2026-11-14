module Core.Mod.Author.Biography.Message.Field.CorrectedBiography where

import Proem
import Data.Maybe (Maybe(..))
import Data.Either (Either(..))
import Control.Monad.Except (runExcept)

import Core.Message.Field.Field (class IsField, Sanitized(..), Presence(..), defaultShouldSanitizeInner)
import Core.Mod.Url.Url (Url)
import Core.Message.Command.Corrected (Corrected(AsIs))
import Core.Message.Command.Corrected (Corrected(..)) as Util
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Newtype (class Newtype)
import Foreign as Foreign

type CorrectedBiography = Util.Corrected (Maybe Url)

newtype CorrectedBiographyField = CorrectedBiographyField CorrectedBiography

description :: String
description = "Biography URL (.docx file)"

instance IsField CorrectedBiographyField CorrectedBiography () where
  name = "CorrectedBiography"

  description = description

  presence = Optional (η AsIs) "No change"

  sanitize json =
    if Foreign.isNull json then Corrected (Util.Corrected Nothing)
    else case runExcept (readImpl json) of
      Left _ -> Intact
      Right (url :: Url) -> Corrected (Util.Corrected (Just url))

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype CorrectedBiographyField _
derive newtype instance ReadForeign CorrectedBiographyField
derive newtype instance WriteForeign CorrectedBiographyField
derive newtype instance Eq CorrectedBiographyField
derive newtype instance Show CorrectedBiographyField
