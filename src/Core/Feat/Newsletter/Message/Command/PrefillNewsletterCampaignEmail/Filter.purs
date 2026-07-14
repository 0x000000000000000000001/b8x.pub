module Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.Filter where

import Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.Payload (Payload)
import Core.Event.Filter (Filter)
import Core.Mod.Newsletter.State as Newsletter

filter :: Payload -> Filter
filter p = Newsletter.filter p.newsletterId
