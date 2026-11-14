module Core.Feat.Reference.Message.Command.CorrectBook.Payload where

import Core.Mod.Book.Cover.Message.Field.CorrectedCover (CorrectedCover, CorrectedCoverField)
import Core.Mod.Book.Id.Message.Field.Book (BookField)
import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Editor.Id.Message.Field.CorrectedEditor (CorrectedEditor, CorrectedEditorField)

type Payload =
  { id :: BookId
  , editor :: CorrectedEditor
  , cover :: CorrectedCover
  }

type Fields =
  ( id :: BookField
  , editor :: CorrectedEditorField
  , cover :: CorrectedCoverField
  )
