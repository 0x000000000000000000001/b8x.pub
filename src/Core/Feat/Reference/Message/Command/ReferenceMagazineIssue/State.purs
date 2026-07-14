module Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.State where

import Proem

import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Payload as ReferenceMagazineIssue
import Core.Mod.MagazineIssue.State as MagazineIssue

type State =
  { magazineIssue :: MagazineIssue.State Ɩ
  }

initialState :: ReferenceMagazineIssue.Payload -> State
initialState _ =
  { magazineIssue: MagazineIssue.initialState
  }
