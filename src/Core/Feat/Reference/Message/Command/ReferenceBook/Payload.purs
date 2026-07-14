module Core.Feat.Reference.Message.Command.ReferenceBook.Payload where

import Core.Feat.Reference.Message.Command.ReferenceBook.Field.CoverUrl (Cover, CoverField)
import Core.Mod.Author.Id.Message.Field.Authors (Authors, AuthorsField)
import Core.Mod.Book.Id.Message.Field.AutoId (Id, IdField)
import Core.Mod.Book.Name.Message.Field (Name, NameField)
import Core.Mod.Book.Year.Message.Field.MaybeYear (Year, YearField)
import Core.Mod.Editor.Id.Message.Field.MaybeEditor (Editor, EditorField)
import Core.Mod.Book.LegacyId.Message.Field (LegacyId, LegacyIdField)

type Payload =
  { id :: Id
  , authors :: Authors
  , editor :: Editor
  , name :: Name
  , year :: Year
  , cover :: Cover
  , legacyId :: LegacyId
  }

type Fields =
  (id :: IdField
  , authors :: AuthorsField
  , editor :: EditorField
  , name :: NameField
  , year :: YearField
  , cover :: CoverField
  , legacyId :: LegacyIdField
  )
