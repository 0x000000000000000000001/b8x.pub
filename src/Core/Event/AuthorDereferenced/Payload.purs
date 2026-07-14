module Core.Event.AuthorDereferenced.Payload where

import Core.Mod.Author.Id.Id (AuthorId)

type Payload =
  { author :: AuthorId
  }
