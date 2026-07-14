module Core.Feat.Reference.Infra.Projection.Postgres.Finder.Index where

import Proem

import Core.Feat.Reference.Message.Query.GetMagazineCalendar.Projection.Projection as GetMagazineCalendar
import Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Projection.Projection as SearchMagazineCustomSections
import Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Projection as SearchAuthors
import Core.Feat.Reference.Message.Query.SearchBooks.Projection.Projection as SearchBooks
import Core.Feat.Reference.Message.Query.SearchEditors.Projection.Projection as SearchEditors
import Core.Feat.Reference.Message.Query.SearchMagazineIssues.Projection.Projection as SearchMagazineIssues
import Core.Feat.Reference.Message.Query.GetAuthor.Projection.Projection as GetAuthor
import Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Projection.Projection as VerifyEditorUniqueness
import Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.Projection.Projection as VerifyAuthorUniqueness
import Core.Feat.Reference.Message.Query.VerifyBookUniqueness.Projection.Projection as VerifyBookUniqueness
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Projection.Projection as VerifyMagazineIssueSlugUniqueness
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueUniqueness.Projection.Projection as VerifyMagazineIssueUniqueness
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Projection.Projection as ReferenceMagazineIssue
import Core.Mod.Projection.Index (PROJECTION_READ_SYNC_PROJECT)
import Infra.Client.Postgres.Postgres (READER_POSTGRES_EDGE_CLIENT)
import Infra.Projection.Postgres.Finder.Finder as Base
import Run (AFF, EFFECT)
import Type.Row (type (+))
import Util.Run.Router (RouterBuilder)

onProjectionReadFind
  :: ∀ fx' a
   . RouterBuilder (PROJECTION_READ_SYNC_PROJECT + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (PROJECTION_READ_SYNC_PROJECT + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
onProjectionReadFind = Base.onProjectionReadFind @GetMagazineCalendar.Calendar
  ◁ Base.onProjectionReadFind @SearchAuthors.Author
  ◁ Base.onProjectionReadFind @SearchBooks.Book
  ◁ Base.onProjectionReadFind @SearchEditors.Editor
  ◁ Base.onProjectionReadFind @SearchMagazineCustomSections.CustomSection
  ◁ Base.onProjectionReadFind @SearchMagazineIssues.MagazineIssue
  ◁ Base.onProjectionReadFind @GetAuthor.Author
  ◁ Base.onProjectionReadFind @VerifyEditorUniqueness.Editor
  ◁ Base.onProjectionReadFind @VerifyAuthorUniqueness.Author
  ◁ Base.onProjectionReadFind @VerifyBookUniqueness.Book
  ◁ Base.onProjectionReadFind @VerifyMagazineIssueSlugUniqueness.MagazineIssue
  ◁ Base.onProjectionReadFind @VerifyMagazineIssueUniqueness.MagazineIssue
  ◁ Base.onProjectionReadFind @ReferenceMagazineIssue.MagazineIssue
