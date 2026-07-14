module Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.Play where

import Core.Event.Event (LoadedEvent)
import Core.Event.Event as Event
import Core.Mod.Newsletter.State as Newsletter
import Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.State (State)

play :: State -> LoadedEvent -> State
play state { event } = case state, event of
  _, Event.NewsletterScheduled p -> Newsletter.Scheduled { scheduledFor: p.scheduledFor, articles: p.articles }
  _, _ -> state
