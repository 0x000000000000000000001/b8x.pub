module Core.Feat.Reference.Message.Command.DereferenceAuthor.Payload where

import Core.Mod.Author.Id.Message.Field.Author (Author, AuthorField)

type Payload =
  { author :: Author
  }

type Fields =
  ( author :: AuthorField
  )
