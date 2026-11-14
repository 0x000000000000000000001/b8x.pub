module Core.Feat.Reference.Message.Command.Index where

import Core.Feat.Reference.Message.Command.DereferenceAuthor.Command (DereferenceAuthor, DereferenceAuthorAliasRow)
import Core.Feat.Reference.Message.Command.DereferenceBook.Command (DereferenceBook, DereferenceBookAliasRow)
import Core.Feat.Reference.Message.Command.DereferenceEditor.Command (DereferenceEditor, DereferenceEditorAliasRow)
import Core.Feat.Reference.Message.Command.ReferenceAuthor.Command (ReferenceAuthor, ReferenceAuthorAliasRow)
import Core.Feat.Reference.Message.Command.ReferenceBook.Command (ReferenceBook, ReferenceBookAliasRow)
import Core.Feat.Reference.Message.Command.CorrectAuthor.Command (CorrectAuthor, CorrectAuthorAliasRow)
import Core.Feat.Reference.Message.Command.CorrectBook.Command (CorrectBook, CorrectBookAliasRow)
import Core.Feat.Reference.Message.Command.ReferenceEditor.Command (ReferenceEditor, ReferenceEditorAliasRow)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Command (ReferenceMagazineIssue)
import Type.Row (type (+))

type ReferenceCommandRow r =
  ( dereferenceAuthor :: DereferenceAuthor
  , dereferenceBook :: DereferenceBook
  , dereferenceEditor :: DereferenceEditor
  , referenceAuthor :: ReferenceAuthor
  , referenceBook :: ReferenceBook
  , correctBook :: CorrectBook
  , correctAuthor :: CorrectAuthor
  , referenceEditor :: ReferenceEditor
  , referenceMagazineIssue :: ReferenceMagazineIssue
  | r
  )

type ReferenceCommandAliasRow r =
  DereferenceAuthorAliasRow
    + DereferenceBookAliasRow
    + DereferenceEditorAliasRow
    + ReferenceAuthorAliasRow
    + ReferenceBookAliasRow
    + CorrectBookAliasRow
    + CorrectAuthorAliasRow
    + ReferenceEditorAliasRow
    + r