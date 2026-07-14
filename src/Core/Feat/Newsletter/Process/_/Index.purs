module Core.Feat.Newsletter.Process.Index where

import Core.Feat.Newsletter.Process.OnNewsletterScheduled.PrefillNewsletterCampaignEmail (PrefillNewsletterCampaignEmailOnNewsletterScheduled)

type NewsletterProcessRow r =
  ( prefillNewsletterCampaignEmailOnNewsletterScheduled :: PrefillNewsletterCampaignEmailOnNewsletterScheduled
  | r
  )
