module Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Play where

import Core.Event.Event (LoadedEvent)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.State (State)
import Core.Mod.MagazineIssue.State as MagazineIssue

play :: State -> LoadedEvent -> State
play { magazineIssue } e =
  { magazineIssue: MagazineIssue.play magazineIssue e
  }
