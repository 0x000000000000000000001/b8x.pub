module Core.Feat.Review.Message.Command.AddMagazineCustomSection.Result where

import Proem

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Mod.MagazineIssue.CustomSection.Exception.MagazineCustomSectionCannotBeAdded (MagazineCustomSectionCannotBeAdded(..))
import Core.Feat.Review.Message.Command.AddMagazineCustomSection.Payload (Payload)
import Core.Feat.Review.Message.Command.AddMagazineCustomSection.State (State)
import Data.Array (head)
import Data.Maybe (Maybe(..))
import Run (Run)
import Type.Row (type (+))

type Result = Ɩ

toResult :: ∀ fx. Payload -> State -> Array Event -> Run (EXCEPT_LOGIC + fx) Result
toResult _ _ events =
  case head events of
    Just (MagazineCustomSectionAdded _) -> ηι
    _ -> throw MagazineCustomSectionCannotBeAdded
