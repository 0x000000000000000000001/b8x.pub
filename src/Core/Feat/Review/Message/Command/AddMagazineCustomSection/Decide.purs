module Core.Feat.Review.Message.Command.AddMagazineCustomSection.Decide where

import Proem hiding (append)

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Mod.MagazineIssue.Exception.MagazineIssueDoesNotExist (MagazineIssueDoesNotExist(..))
import Core.Mod.MagazineIssue.CustomSection.Exception.MagazineCustomSectionAlreadyAdded (MagazineCustomSectionAlreadyAdded(..))
import Core.Feat.Review.Message.Command.AddMagazineCustomSection.Payload (Payload)
import Core.Feat.Review.Message.Command.AddMagazineCustomSection.State (State)
import Core.Mod.MagazineIssue.State as MagazineIssue
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (EXCEPT_LOGIC + fx) (Array Event)
decide state payload =
  if state.sectionAlreadyAdded then throw MagazineCustomSectionAlreadyAdded
  else case state.magazineIssue of
    MagazineIssue.Referenced _ ->
      η
        [ MagazineCustomSectionAdded
            { id: payload.id
            , magazineIssue: payload.magazineIssue
            , name: payload.name
            }
        ]
    _ -> throw MagazineIssueDoesNotExist
