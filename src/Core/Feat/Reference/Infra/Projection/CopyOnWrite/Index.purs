module Core.Feat.Reference.Infra.Projection.CopyOnWrite.Index where

import Proem

import Core.Feat.Reference.Message.Query.GetMagazineCalendar.Infra.Projection.CopyOnWrite (GET_MAGAZINE_CALENDAR_PROJECTION_WRITE_COPY_PERSIST, GET_MAGAZINE_CALENDAR_PROJECTION_WRITE_COPY_STATE, getMagazineCalendarProjectionWriteCopyState')
import Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Infra.Projection.CopyOnWrite (SEARCH_MAGAZINE_CUSTOM_SECTIONS_PROJECTION_WRITE_COPY_PERSIST, SEARCH_MAGAZINE_CUSTOM_SECTIONS_PROJECTION_WRITE_COPY_STATE, searchMagazineCustomSectionsProjectionWriteCopyState')
import Core.Feat.Reference.Message.Query.SearchAuthors.Infra.Projection.CopyOnWrite (SEARCH_AUTHORS_PROJECTION_WRITE_COPY_PERSIST, SEARCH_AUTHORS_PROJECTION_WRITE_COPY_STATE, searchAuthorsProjectionWriteCopyState')
import Core.Feat.Reference.Message.Query.SearchBooks.Infra.Projection.CopyOnWrite (SEARCH_BOOKS_PROJECTION_WRITE_COPY_PERSIST, SEARCH_BOOKS_PROJECTION_WRITE_COPY_STATE, searchBooksProjectionWriteCopyState')
import Core.Feat.Reference.Message.Query.SearchEditors.Infra.Projection.CopyOnWrite (SEARCH_EDITORS_PROJECTION_WRITE_COPY_PERSIST, SEARCH_EDITORS_PROJECTION_WRITE_COPY_STATE, searchEditorsProjectionWriteCopyState')
import Core.Feat.Reference.Message.Query.SearchMagazineIssues.Infra.Projection.CopyOnWrite (SEARCH_MAGAZINE_ISSUES_PROJECTION_WRITE_COPY_PERSIST, SEARCH_MAGAZINE_ISSUES_PROJECTION_WRITE_COPY_STATE, searchMagazineIssuesProjectionWriteCopyState')
import Core.Feat.Reference.Message.Query.GetAuthor.Infra.Projection.CopyOnWrite (GET_AUTHOR_PROJECTION_WRITE_COPY_PERSIST, GET_AUTHOR_PROJECTION_WRITE_COPY_STATE, getAuthorProjectionWriteCopyState')
import Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Infra.Projection.CopyOnWrite (VERIFY_EDITOR_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST, VERIFY_EDITOR_UNIQUENESS_PROJECTION_WRITE_COPY_STATE, verifyEditorUniquenessProjectionWriteCopyState')
import Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.Infra.Projection.CopyOnWrite (VERIFY_AUTHOR_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST, VERIFY_AUTHOR_UNIQUENESS_PROJECTION_WRITE_COPY_STATE, verifyAuthorUniquenessProjectionWriteCopyState')
import Core.Feat.Reference.Message.Query.VerifyBookUniqueness.Infra.Projection.CopyOnWrite (VERIFY_BOOK_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST, VERIFY_BOOK_UNIQUENESS_PROJECTION_WRITE_COPY_STATE, verifyBookUniquenessProjectionWriteCopyState')
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Infra.Projection.CopyOnWrite (VERIFY_MAGAZINE_ISSUE_SLUG_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST, VERIFY_MAGAZINE_ISSUE_SLUG_UNIQUENESS_PROJECTION_WRITE_COPY_STATE, verifyMagazineIssueSlugUniquenessProjectionWriteCopyState')
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueUniqueness.Infra.Projection.CopyOnWrite (VERIFY_MAGAZINE_ISSUE_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST, VERIFY_MAGAZINE_ISSUE_UNIQUENESS_PROJECTION_WRITE_COPY_STATE, verifyMagazineIssueUniquenessProjectionWriteCopyState')
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Infra.Projection.CopyOnWrite (REFERENCE_MAGAZINE_ISSUE_PROJECTION_WRITE_COPY_PERSIST, REFERENCE_MAGAZINE_ISSUE_PROJECTION_WRITE_COPY_STATE, referenceMagazineIssueProjectionWriteCopyState')
import Data.Map as Map
import Run (Run)
import Run.State (evalStateAt)
import Type.Row (type (+))

evalProjectionWriteCopyState
  :: ∀ fx a
   . Run (REFERENCE_PROJECTION_WRITE_COPY_STATE + fx) a
  -> Run fx a
evalProjectionWriteCopyState =
  evalStateAt getMagazineCalendarProjectionWriteCopyState' Map.empty
    ▷ evalStateAt searchAuthorsProjectionWriteCopyState' Map.empty
    ▷ evalStateAt searchBooksProjectionWriteCopyState' Map.empty
    ▷ evalStateAt searchEditorsProjectionWriteCopyState' Map.empty
    ▷ evalStateAt searchMagazineCustomSectionsProjectionWriteCopyState' Map.empty
    ▷ evalStateAt searchMagazineIssuesProjectionWriteCopyState' Map.empty
    ▷ evalStateAt getAuthorProjectionWriteCopyState' Map.empty
    ▷ evalStateAt verifyBookUniquenessProjectionWriteCopyState' Map.empty
    ▷ evalStateAt verifyAuthorUniquenessProjectionWriteCopyState' Map.empty
    ▷ evalStateAt verifyEditorUniquenessProjectionWriteCopyState' Map.empty
    ▷ evalStateAt verifyMagazineIssueSlugUniquenessProjectionWriteCopyState' Map.empty
    ▷ evalStateAt verifyMagazineIssueUniquenessProjectionWriteCopyState' Map.empty
    ▷ evalStateAt referenceMagazineIssueProjectionWriteCopyState' Map.empty

type REFERENCE_PROJECTION_WRITE_COPY_STATE fx =
  GET_MAGAZINE_CALENDAR_PROJECTION_WRITE_COPY_STATE
    + SEARCH_AUTHORS_PROJECTION_WRITE_COPY_STATE
    + SEARCH_BOOKS_PROJECTION_WRITE_COPY_STATE
    + SEARCH_EDITORS_PROJECTION_WRITE_COPY_STATE
    + SEARCH_MAGAZINE_CUSTOM_SECTIONS_PROJECTION_WRITE_COPY_STATE
    + SEARCH_MAGAZINE_ISSUES_PROJECTION_WRITE_COPY_STATE
    + GET_AUTHOR_PROJECTION_WRITE_COPY_STATE
    + VERIFY_EDITOR_UNIQUENESS_PROJECTION_WRITE_COPY_STATE
    + VERIFY_AUTHOR_UNIQUENESS_PROJECTION_WRITE_COPY_STATE
    + VERIFY_MAGAZINE_ISSUE_SLUG_UNIQUENESS_PROJECTION_WRITE_COPY_STATE
    + VERIFY_MAGAZINE_ISSUE_UNIQUENESS_PROJECTION_WRITE_COPY_STATE
    + VERIFY_BOOK_UNIQUENESS_PROJECTION_WRITE_COPY_STATE
    + REFERENCE_MAGAZINE_ISSUE_PROJECTION_WRITE_COPY_STATE
    + fx

type REFERENCE_PROJECTION_WRITE_COPY_PERSIST fx =
  GET_MAGAZINE_CALENDAR_PROJECTION_WRITE_COPY_PERSIST
    + SEARCH_AUTHORS_PROJECTION_WRITE_COPY_PERSIST
    + SEARCH_BOOKS_PROJECTION_WRITE_COPY_PERSIST
    + SEARCH_EDITORS_PROJECTION_WRITE_COPY_PERSIST
    + SEARCH_MAGAZINE_CUSTOM_SECTIONS_PROJECTION_WRITE_COPY_PERSIST
    + SEARCH_MAGAZINE_ISSUES_PROJECTION_WRITE_COPY_PERSIST
    + GET_AUTHOR_PROJECTION_WRITE_COPY_PERSIST
    + VERIFY_EDITOR_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST
    + VERIFY_AUTHOR_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST
    + VERIFY_MAGAZINE_ISSUE_SLUG_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST
    + VERIFY_MAGAZINE_ISSUE_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST
    + VERIFY_BOOK_UNIQUENESS_PROJECTION_WRITE_COPY_PERSIST
    + REFERENCE_MAGAZINE_ISSUE_PROJECTION_WRITE_COPY_PERSIST
    + fx

type REFERENCE_PROJECTION_WRITE_COPY fx =
  REFERENCE_PROJECTION_WRITE_COPY_STATE
    + REFERENCE_PROJECTION_WRITE_COPY_PERSIST
    + fx
