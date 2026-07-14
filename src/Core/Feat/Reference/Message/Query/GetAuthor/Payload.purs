module Core.Feat.Reference.Message.Query.GetAuthor.Payload where

import Core.Mod.Author.Id.Message.Field.Id (IdField)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Feat.Reference.Message.Query.GetAuthor.Field.Needs (Needs, NeedsField)

type Payload =
  { id :: AuthorId
  , needs :: Needs
  }

type Fields =
  ( id :: IdField
  , needs :: NeedsField
  )
