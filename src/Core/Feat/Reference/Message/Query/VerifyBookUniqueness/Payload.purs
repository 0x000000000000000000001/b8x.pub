module Core.Feat.Reference.Message.Query.VerifyBookUniqueness.Payload where

import Core.Mod.Book.Name.Message.Field (Name, NameField)
import Core.Mod.Author.Id.Message.Field.Authors (Authors, AuthorsField)
import Core.Mod.Editor.Id.Message.Field.MaybeEditor (Editor, EditorField)

type Fields =
  ( name ∷ NameField
  , authors ∷ AuthorsField
  , editor ∷ EditorField
  )

type Payload =
  { name ∷ Name
  , authors ∷ Authors
  , editor ∷ Editor
  }
