module Core.Mod.Author.Message.Query.Result where

import Core.Message.Query.Result (Return)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name

import Core.Mod.Image.Message.Query.Result (Image)
import Data.Maybe (Maybe)
import Core.Mod.Author.Biography.Biography (Biography)

type Author =
  { id :: Return AuthorId
  , name :: Return Name
  , biography :: Return Biography
  , portrait :: Return (Maybe Image)
  }
