module Core.Feat.Newsletter.Message.Command.Index where

import Core.Feat.Newsletter.Message.Command.AddNewsletterSubscriber.Command (AddNewsletterSubscriber)
import Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.Command (PrefillNewsletterCampaignEmail)

type NewsletterCommandRow r =
  ( addNewsletterSubscriber :: AddNewsletterSubscriber
  , prefillNewsletterCampaignEmail :: PrefillNewsletterCampaignEmail
  | r
  )
