module Core.Mod.Book.Cover.Message.Field.CorrectedCover where

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

type CorrectedCover = Util.Corrected (Maybe Url)

newtype CorrectedCoverField = CorrectedCoverField CorrectedCover

description :: String
description = "Cover URL"

instance IsField CorrectedCoverField CorrectedCover () where
  name = "CorrectedCover"

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

derive instance Newtype CorrectedCoverField _
derive newtype instance ReadForeign CorrectedCoverField
derive newtype instance WriteForeign CorrectedCoverField
derive newtype instance Eq CorrectedCoverField
derive newtype instance Show CorrectedCoverField
