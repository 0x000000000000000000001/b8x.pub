module Core.Event.AuthorReferenced.Payload where

import Core.Mod.Author.Biography.Biography (Biography)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.LegacyIds.LegacyIds (LegacyIds)
import Core.Mod.Author.Name.Name (Name)
import Core.Mod.Image.Image (Image)
import Data.Maybe (Maybe)

type Payload =
  { id :: AuthorId
  , name :: Name
  , biography :: Biography
  , legacyIds :: LegacyIds
  , portrait :: Maybe Image
  }
