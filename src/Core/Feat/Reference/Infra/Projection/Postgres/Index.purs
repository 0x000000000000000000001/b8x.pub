module Core.Feat.Reference.Infra.Projection.Postgres.Index where

import Proem

import Core.Feat.Reference.Projection.Index (REFERENCE_PROJECTION_WRITE_OPS)
import Core.Feat.Reference.Infra.Projection.CopyOnWrite.Index (REFERENCE_PROJECTION_WRITE_COPY_PERSIST)
import Core.Feat.Reference.Message.Query.GetMagazineCalendar.Projection.Projection (GetMagazineCalendarProjection)
import Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Projection.Projection (SearchMagazineCustomSectionsProjection)
import Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Projection (SearchAuthorsProjection)
import Core.Feat.Reference.Message.Query.SearchBooks.Projection.Projection (SearchBooksProjection)
import Core.Feat.Reference.Message.Query.SearchEditors.Projection.Projection (SearchEditorsProjection)
import Core.Feat.Reference.Message.Query.SearchMagazineIssues.Projection.Projection (SearchMagazineIssuesProjection)
import Core.Feat.Reference.Message.Query.GetAuthor.Projection.Projection (GetAuthorProjection)
import Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Projection.Projection (VerifyEditorUniquenessProjection)
import Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.Projection.Projection (VerifyAuthorUniquenessProjection)
import Core.Feat.Reference.Message.Query.VerifyBookUniqueness.Projection.Projection (VerifyBookUniquenessProjection)
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Projection.Projection (VerifyMagazineIssueSlugUniquenessProjection)
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueUniqueness.Projection.Projection (VerifyMagazineIssueUniquenessProjection)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Projection.Projection (ReferenceMagazineIssueProjection)
import Core.Mod.Infra.Projection.CopyOnWrite.Index (PROJECTION_WRITE_COPY_STATE)
import Infra.Client.Postgres.Postgres (READER_POSTGRES_EDGE_CLIENT, READER_POSTGRES_STORE_CLIENT)
import Infra.Projection.Postgres.Projection as Base
import Run (AFF, EFFECT)
import Type.Row (type (+))
import Util.Run.Router (RouterBuilder)

onProjectionWriteOps
  :: ∀ fx' a
   . RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
onProjectionWriteOps = Base.onProjectionWriteOps @GetMagazineCalendarProjection
  ◁ Base.onProjectionWriteOps @SearchAuthorsProjection
  ◁ Base.onProjectionWriteOps @SearchBooksProjection
  ◁ Base.onProjectionWriteOps @SearchEditorsProjection
  ◁ Base.onProjectionWriteOps @SearchMagazineCustomSectionsProjection
  ◁ Base.onProjectionWriteOps @SearchMagazineIssuesProjection
  ◁ Base.onProjectionWriteOps @GetAuthorProjection
  ◁ Base.onProjectionWriteOps @VerifyMagazineIssueSlugUniquenessProjection
  ◁ Base.onProjectionWriteOps @VerifyEditorUniquenessProjection
  ◁ Base.onProjectionWriteOps @VerifyAuthorUniquenessProjection
  ◁ Base.onProjectionWriteOps @VerifyBookUniquenessProjection
  ◁ Base.onProjectionWriteOps @VerifyMagazineIssueUniquenessProjection
  ◁ Base.onProjectionWriteOps @ReferenceMagazineIssueProjection

onProjectionWriteCopyPersist
  :: ∀ fx' a
   . RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (PROJECTION_WRITE_COPY_STATE + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
onProjectionWriteCopyPersist = Base.onProjectionWriteCopyPersist @GetMagazineCalendarProjection
  ◁ Base.onProjectionWriteCopyPersist @SearchAuthorsProjection
  ◁ Base.onProjectionWriteCopyPersist @SearchBooksProjection
  ◁ Base.onProjectionWriteCopyPersist @SearchEditorsProjection
  ◁ Base.onProjectionWriteCopyPersist @SearchMagazineCustomSectionsProjection
  ◁ Base.onProjectionWriteCopyPersist @SearchMagazineIssuesProjection
  ◁ Base.onProjectionWriteCopyPersist @GetAuthorProjection
  ◁ Base.onProjectionWriteCopyPersist @VerifyMagazineIssueSlugUniquenessProjection
  ◁ Base.onProjectionWriteCopyPersist @VerifyEditorUniquenessProjection
  ◁ Base.onProjectionWriteCopyPersist @VerifyAuthorUniquenessProjection
  ◁ Base.onProjectionWriteCopyPersist @VerifyBookUniquenessProjection
  ◁ Base.onProjectionWriteCopyPersist @VerifyMagazineIssueUniquenessProjection
  ◁ Base.onProjectionWriteCopyPersist @ReferenceMagazineIssueProjection

onProjectionReadSyncProject
  :: ∀ fx' a
   . RouterBuilder (REFERENCE_PROJECTION_WRITE_OPS + PROJECTION_WRITE_COPY_STATE + REFERENCE_PROJECTION_WRITE_COPY_PERSIST + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (REFERENCE_PROJECTION_WRITE_OPS + PROJECTION_WRITE_COPY_STATE + REFERENCE_PROJECTION_WRITE_COPY_PERSIST + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx') a
onProjectionReadSyncProject = Base.onProjectionReadSyncProject @GetMagazineCalendarProjection
  ◁ Base.onProjectionReadSyncProject @SearchAuthorsProjection
  ◁ Base.onProjectionReadSyncProject @SearchBooksProjection
  ◁ Base.onProjectionReadSyncProject @SearchEditorsProjection
  ◁ Base.onProjectionReadSyncProject @SearchMagazineCustomSectionsProjection
  ◁ Base.onProjectionReadSyncProject @SearchMagazineIssuesProjection
  ◁ Base.onProjectionReadSyncProject @GetAuthorProjection
  ◁ Base.onProjectionReadSyncProject @VerifyMagazineIssueSlugUniquenessProjection
  ◁ Base.onProjectionReadSyncProject @VerifyEditorUniquenessProjection
  ◁ Base.onProjectionReadSyncProject @VerifyAuthorUniquenessProjection
  ◁ Base.onProjectionReadSyncProject @VerifyBookUniquenessProjection
  ◁ Base.onProjectionReadSyncProject @VerifyMagazineIssueUniquenessProjection
  ◁ Base.onProjectionReadSyncProject @ReferenceMagazineIssueProjection

onProjectionReadSyncProjectWithNoop
  :: ∀ fx' a
   . RouterBuilder fx' a
  -> RouterBuilder fx' a
onProjectionReadSyncProjectWithNoop = Base.onProjectionReadSyncProjectWithNoop @GetMagazineCalendarProjection
  ◁ Base.onProjectionReadSyncProjectWithNoop @SearchAuthorsProjection
  ◁ Base.onProjectionReadSyncProjectWithNoop @SearchBooksProjection
  ◁ Base.onProjectionReadSyncProjectWithNoop @SearchEditorsProjection
  ◁ Base.onProjectionReadSyncProjectWithNoop @SearchMagazineCustomSectionsProjection
  ◁ Base.onProjectionReadSyncProjectWithNoop @SearchMagazineIssuesProjection
  ◁ Base.onProjectionReadSyncProjectWithNoop @GetAuthorProjection
  ◁ Base.onProjectionReadSyncProjectWithNoop @VerifyMagazineIssueSlugUniquenessProjection
  ◁ Base.onProjectionReadSyncProjectWithNoop @VerifyEditorUniquenessProjection
  ◁ Base.onProjectionReadSyncProjectWithNoop @VerifyAuthorUniquenessProjection
  ◁ Base.onProjectionReadSyncProjectWithNoop @VerifyBookUniquenessProjection
  ◁ Base.onProjectionReadSyncProjectWithNoop @VerifyMagazineIssueUniquenessProjection
  ◁ Base.onProjectionReadSyncProjectWithNoop @ReferenceMagazineIssueProjection
