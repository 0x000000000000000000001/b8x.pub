module Core.Feat.Review.Message.Command.AddMagazineCustomSection.Filter where

import Core.Event.Filter (Filter(..), by)
import Core.Event.MagazineCustomSectionAdded.MagazineCustomSectionAdded (MagazineCustomSectionAdded)
import Core.Feat.Review.Message.Command.AddMagazineCustomSection.Payload (Payload)
import Core.Mod.MagazineIssue.State as MagazineIssue

filter :: Payload -> Filter
filter payload =
  Or (MagazineIssue.filter payload.magazineIssue)
    (by @MagazineCustomSectionAdded @"id" payload.id)
