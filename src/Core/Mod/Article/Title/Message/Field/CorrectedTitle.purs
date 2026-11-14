module Core.Mod.Article.Title.Message.Field.CorrectedTitle where

import Proem
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Control.Monad.Except (runExcept)

import Core.Message.Field.Field (class IsField, Sanitized(..), Presence(..), defaultShouldSanitizeInner)
import Core.Mod.Article.Title.Title (Title)
import Core.Message.Command.Corrected (Corrected(AsIs))
import Core.Message.Command.Corrected (Corrected(..)) as Util
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Newtype (class Newtype)

type CorrectedTitle = Util.Corrected Title

newtype CorrectedTitleField = CorrectedTitleField CorrectedTitle

description :: String
description = "Title (HTML)"

instance IsField CorrectedTitleField CorrectedTitle () where
  name = "CorrectedTitle"

  description = description

  presence = Optional (η AsIs) "No change"

  sanitize json = case runExcept (readImpl json) of
    Left _ -> Intact
    Right (title :: Title) -> Corrected (Util.Corrected title)

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype CorrectedTitleField _
derive newtype instance ReadForeign CorrectedTitleField
derive newtype instance WriteForeign CorrectedTitleField
derive newtype instance Eq CorrectedTitleField
derive newtype instance Show CorrectedTitleField
