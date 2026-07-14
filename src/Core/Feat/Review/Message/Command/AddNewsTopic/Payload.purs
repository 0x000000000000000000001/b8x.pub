module Core.Feat.Review.Message.Command.AddNewsTopic.Payload where

import Core.Mod.NewsTopic.Id.Message.Field.AutoId (Id, IdField)
import Core.Mod.NewsTopic.SearchInput.Message.Field (SearchInput, SearchInputField)

type Payload =
  { id :: Id
  , searchInput :: SearchInput
  }

type Fields =
  (id :: IdField
  , searchInput :: SearchInputField
  )
