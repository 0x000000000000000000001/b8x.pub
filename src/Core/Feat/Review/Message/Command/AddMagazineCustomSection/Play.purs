module Core.Feat.Review.Message.Command.AddMagazineCustomSection.Play where

import Core.Event.Event (Event(..), LoadedEvent)
import Core.Feat.Review.Message.Command.AddMagazineCustomSection.State (State)
import Core.Mod.MagazineIssue.State as MagazineIssue

play :: State -> LoadedEvent -> State
play state loaded@{ event } = case event of
  MagazineCustomSectionAdded _ -> state { sectionAlreadyAdded = true }
  _ -> state { magazineIssue = MagazineIssue.play state.magazineIssue loaded }
