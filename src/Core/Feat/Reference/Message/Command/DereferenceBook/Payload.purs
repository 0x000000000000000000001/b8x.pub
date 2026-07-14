module Core.Feat.Reference.Message.Command.DereferenceBook.Payload where

import Core.Mod.Book.Id.Message.Field.Book (Book, BookField)

type Payload =
  { book :: Book
  }

type Fields =
  (book :: BookField
  )
