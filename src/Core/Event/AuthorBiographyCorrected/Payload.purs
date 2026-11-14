module Core.Event.AuthorBiographyCorrected.Payload where

import Core.Mod.Author.Biography.Biography (Biography)
import Core.Mod.Author.Id.Id (AuthorId)

type Payload =
  { author :: AuthorId
  , biography :: Biography
  }
