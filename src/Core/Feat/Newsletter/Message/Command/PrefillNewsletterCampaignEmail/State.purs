module Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.State where


import Core.Mod.Time.Instant (Instant)
import Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.Payload (Payload)
import Core.Mod.Article.Id.Id (ArticleId)

import Core.Mod.Newsletter.State as Newsletter

type State = Newsletter.State { scheduledFor :: Instant, articles :: Array ArticleId }

initialState :: Payload -> State
initialState _ = Newsletter.initialState


