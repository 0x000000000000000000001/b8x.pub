module Core.Feat.Reference.Message.Command.Index where

import Core.Feat.Reference.Message.Command.DereferenceAuthor.Command (DereferenceAuthor)
import Core.Feat.Reference.Message.Command.DereferenceBook.Command (DereferenceBook)
import Core.Feat.Reference.Message.Command.DereferenceEditor.Command (DereferenceEditor)
import Core.Feat.Reference.Message.Command.ReferenceAuthor.Command (ReferenceAuthor)
import Core.Feat.Reference.Message.Command.ReferenceBook.Command (ReferenceBook)
import Core.Feat.Reference.Message.Command.ReferenceEditor.Command (ReferenceEditor)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Command (ReferenceMagazineIssue)

type ReferenceCommandRow r =
  (dereferenceAuthor :: DereferenceAuthor
  , dereferenceBook :: DereferenceBook
  , dereferenceEditor :: DereferenceEditor
  , referenceAuthor :: ReferenceAuthor
  , referenceBook :: ReferenceBook
  , referenceEditor :: ReferenceEditor
  , referenceMagazineIssue :: ReferenceMagazineIssue
  | r
  )