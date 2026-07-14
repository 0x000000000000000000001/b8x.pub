module Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Filter where

import Core.Event.Filter (Filter)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Payload (Payload)
import Core.Mod.MagazineIssue.State as MagazineIssue

filter :: Payload -> Filter
filter { id } = MagazineIssue.filter id
