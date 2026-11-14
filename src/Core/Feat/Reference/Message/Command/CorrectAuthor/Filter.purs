module Core.Feat.Reference.Message.Command.CorrectAuthor.Filter where

import Proem hiding ((&&), (||))

import Core.Event.AuthorBiographyCorrected.AuthorBiographyCorrected (AuthorBiographyCorrected)
import Core.Event.Filter (Filter(..), by)
import Core.Feat.Reference.Message.Command.CorrectAuthor.Payload (Payload)
import Core.Mod.Author.State as Author

filter :: Payload -> Filter
filter { id } =
  Or (Author.filter id)
    (by @AuthorBiographyCorrected @"author" id)
