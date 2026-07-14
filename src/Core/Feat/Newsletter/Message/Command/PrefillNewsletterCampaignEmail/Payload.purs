module Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.Payload where

import Core.Mod.Newsletter.Id.Id (NewsletterId)
import Core.Mod.Newsletter.Id.Message.Field.Id (NewsletterIdField)

type Payload =
  { newsletterId :: NewsletterId
  }

type Fields =
  ( newsletterId :: NewsletterIdField
  )
