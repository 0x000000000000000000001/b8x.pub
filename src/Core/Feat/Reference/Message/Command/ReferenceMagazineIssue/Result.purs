module Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Result where

import Proem

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Exception.MagazineIssueCannotBeReferenced (MagazineIssueCannotBeReferenced(..))
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Payload (Payload)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.State (State)
import Core.Mod.MagazineIssue.Id.Message.Field.AutoId (Id)
import Data.Array (head)
import Data.Maybe (Maybe(..))
import Run (Run)
import Type.Row (type (+))
import Core.Mod.MagazineIssue.Slug.Slug (Slug)

type Result = { id :: Id, slug :: Slug }

toResult :: ∀ fx. Payload -> State -> Array Event -> Run (EXCEPT_LOGIC + fx) Result
toResult _ _ events =
  case head events of
    Just (MagazineIssueReferenced { id, slug }) -> η { id, slug }
    _ -> throw MagazineIssueCannotBeReferenced
