module Core.Feat.Reference.Message.Query.Exception.Index where

import Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Exception.Index (SearchMagazineCustomSectionsExceptionRow)
import Core.Feat.Reference.Message.Query.SearchMagazineIssues.Exception.Index (SearchMagazineIssuesExceptionRow)
import Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Exception.Index (VerifyEditorUniquenessExceptionRow)
import Core.Feat.Reference.Message.Query.SearchEditors.Exception.Index (SearchEditorsQueryExceptionRow)
import Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Exception.Index (SearchAuthorsProjectionExceptionRow)
import Core.Feat.Reference.Message.Query.SearchBooks.Exception.Index (SearchBooksQueryExceptionRow)
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Exception.Index (VerifyMagazineIssueSlugUniquenessExceptionRow)
import Type.Row (type (+))

type ReferenceQueryExceptionRow r =
  VerifyMagazineIssueSlugUniquenessExceptionRow
    + VerifyEditorUniquenessExceptionRow
    + SearchMagazineCustomSectionsExceptionRow
    + SearchMagazineIssuesExceptionRow
    + SearchEditorsQueryExceptionRow
    + SearchAuthorsProjectionExceptionRow
    + SearchBooksQueryExceptionRow
    + r
