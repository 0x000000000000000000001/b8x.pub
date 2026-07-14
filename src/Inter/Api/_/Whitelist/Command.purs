module Inter.Api.Whitelist.Command where

import Core.Feat.Membership.Message.Command.RegisterUser.Command (RegisterUser)
import Core.Feat.Reference.Message.Command.DereferenceAuthor.Command (DereferenceAuthor)
import Core.Feat.Reference.Message.Command.DereferenceEditor.Command (DereferenceEditor)
import Core.Feat.Reference.Message.Command.ReferenceAuthor.Command (ReferenceAuthor)
import Core.Feat.Reference.Message.Command.ReferenceBook.Command (ReferenceBook)
import Core.Feat.Reference.Message.Command.ReferenceEditor.Command (ReferenceEditor)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Command (ReferenceMagazineIssue)
import Core.Feat.Review.Message.Command.WriteArticle.Command (WriteArticle)
import Core.Feat.Review.Message.Command.AddNewsTopic.Command (AddNewsTopic)
import Core.Feat.Review.Message.Command.TrackArticleRead.Command (TrackArticleRead)
import Core.Feat.Newsletter.Message.Command.AddNewsletterSubscriber.Command (AddNewsletterSubscriber)
import Core.Feat.Review.Message.Command.ScheduleNewsletter.Command (ScheduleNewsletter)
import Core.Feat.Review.Message.Command.QuoteArticle.Command (QuoteArticle)
import Core.Feat.Review.Message.Command.AddMagazineCustomSection.Command (AddMagazineCustomSection)

type CommandRow =
  (dereferenceAuthor :: DereferenceAuthor
  , dereferenceEditor :: DereferenceEditor
  , referenceAuthor :: ReferenceAuthor
  , referenceBook :: ReferenceBook
  , referenceEditor :: ReferenceEditor
  , referenceMagazineIssue :: ReferenceMagazineIssue
  , registerUser :: RegisterUser
  , writeArticle :: WriteArticle
  , addNewsTopic :: AddNewsTopic
  , trackArticleRead :: TrackArticleRead
  , addNewsletterSubscriber :: AddNewsletterSubscriber
  , scheduleNewsletter :: ScheduleNewsletter
  , quoteArticle :: QuoteArticle
  , addMagazineCustomSection :: AddMagazineCustomSection
  )
