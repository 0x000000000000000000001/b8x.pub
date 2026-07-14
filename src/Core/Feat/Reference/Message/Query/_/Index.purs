module Core.Feat.Reference.Message.Query.Index where

import Core.Feat.Reference.Message.Query.SearchAuthors.Query (SearchAuthors)
import Core.Feat.Reference.Message.Query.SearchEditors.Query (SearchEditors)
import Core.Feat.Reference.Message.Query.GetMagazineCalendar.Query (GetMagazineCalendar)
import Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Query (SearchMagazineCustomSections)
import Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Query (VerifyEditorUniqueness)
import Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.Query (VerifyAuthorUniqueness)
import Core.Feat.Reference.Message.Query.VerifyBookUniqueness.Query (VerifyBookUniqueness)
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Query (VerifyMagazineIssueSlugUniqueness)
import Core.Feat.Reference.Message.Query.VerifyMagazineIssueUniqueness.Query (VerifyMagazineIssueUniqueness)

type ReferenceQueryRow r =
  ( searchAuthors :: SearchAuthors
  , searchEditors :: SearchEditors
  , getMagazineCalendar :: GetMagazineCalendar
  , searchMagazineCustomSections :: SearchMagazineCustomSections
  , verifyAuthorUniqueness :: VerifyAuthorUniqueness
  , verifyEditorUniqueness :: VerifyEditorUniqueness
  , verifyBookUniqueness :: VerifyBookUniqueness
  , verifyMagazineIssueSlugUniqueness :: VerifyMagazineIssueSlugUniqueness
  , verifyMagazineIssueUniqueness :: VerifyMagazineIssueUniqueness
  | r
  )
