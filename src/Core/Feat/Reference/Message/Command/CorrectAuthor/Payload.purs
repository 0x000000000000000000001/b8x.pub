module Core.Feat.Reference.Message.Command.CorrectAuthor.Payload where

import Core.Mod.Author.Biography.Message.Field.CorrectedBiography (CorrectedBiography, CorrectedBiographyField)
import Core.Mod.Author.Id.Message.Field.Author (Author, AuthorField)

type Payload =
  { id :: Author
  , biography :: CorrectedBiography
  }

type Fields =
  ( id :: AuthorField
  , biography :: CorrectedBiographyField
  )
