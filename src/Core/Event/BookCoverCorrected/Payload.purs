module Core.Event.BookCoverCorrected.Payload where

import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Image.Image (Image)
import Data.Maybe (Maybe)

type Payload =
  { book :: BookId
  , cover :: Maybe Image
  }
