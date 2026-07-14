module Core.Feat.Reference.Message.Query.SearchAuthors.Result where

import Core.Mod.Author.Biography.Biography (Biography)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.LegacyIds.LegacyIds (LegacyIds)
import Core.Mod.Author.Name.Name (Name)
import Core.Message.Query.Result (Return)
import Data.Maybe (Maybe)
import Core.Mod.Image.Message.Query.Result (Image)

type Result =
  { authors ::
      Array
        { id :: Return AuthorId
        , name :: Return Name
        , biography :: Return Biography
        , legacyIds :: Return LegacyIds
        , portrait :: Return (Maybe Image)
        }
  , limit :: Int
  , hasNextPage :: Boolean
  }
