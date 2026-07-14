module Core.Feat.Review.Message.Command.AddMagazineCustomSection.State where

import Proem

import Core.Feat.Review.Message.Command.AddMagazineCustomSection.Payload as AddMagazineCustomSection
import Core.Mod.MagazineIssue.State as MagazineIssue

type State =
  { magazineIssue :: MagazineIssue.State Ɩ
  , sectionAlreadyAdded :: Boolean
  }

initialState :: AddMagazineCustomSection.Payload -> State
initialState _ =
  { magazineIssue: MagazineIssue.initialState
  , sectionAlreadyAdded: false
  }
