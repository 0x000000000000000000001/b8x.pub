module Core.Event.BookDereferenced.Payload where

import Core.Mod.Book.Id.Id (BookId)

type Payload =
  { book :: BookId
  }
