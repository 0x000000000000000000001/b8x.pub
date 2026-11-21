module Core.Mod.Article.Lead.Message.Field.CorrectedLead where

import Proem
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Control.Monad.Except (runExcept)

import Core.Message.Field.Field (class IsField, Sanitized(..), Presence(..), defaultShouldSanitizeInner)
import Core.Mod.Article.Lead.Lead (Lead)
import Core.Message.Command.Corrected (Corrected(AsIs))
import Core.Message.Command.Corrected (Corrected(..)) as Util
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Newtype (class Newtype)

type CorrectedLead = Util.Corrected Lead

newtype CorrectedLeadField = CorrectedLeadField CorrectedLead

description :: String
description = "Lead (HTML)"

instance IsField CorrectedLeadField CorrectedLead () where
  name = "CorrectedLead"

  description = description

  presence = Optional (η AsIs) "No change"

  sanitize json = case runExcept (readImpl json) of
    Left _ -> Intact
    Right (lead :: Lead) -> Corrected (Util.Corrected lead)

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype CorrectedLeadField _
derive newtype instance ReadForeign CorrectedLeadField
derive newtype instance WriteForeign CorrectedLeadField
derive newtype instance Eq CorrectedLeadField
derive newtype instance Show CorrectedLeadField
