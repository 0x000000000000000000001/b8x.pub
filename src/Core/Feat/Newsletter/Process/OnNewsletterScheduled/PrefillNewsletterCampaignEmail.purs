module Core.Feat.Newsletter.Process.OnNewsletterScheduled.PrefillNewsletterCampaignEmail where

import Proem

import Core.Event.NewsletterScheduled.Payload (Payload)
import Core.Event.NewsletterScheduled.NewsletterScheduled (NewsletterScheduled)
import Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.Command (PrefillNewsletterCampaignEmail(..)) as Command
import Core.Feat.Process.Process (class IsProcess)
import Util.Type.Type (class Reflect)
import Core.Message.Queue (queueCommand)
import Core.Feat.Effect.Generate (now)
import Core.Mod.Time.Instant (Instant(..))
import Data.DateTime.Instant as Base
import Data.Time.Duration (Milliseconds(..))

data PrefillNewsletterCampaignEmailOnNewsletterScheduled

instance Reflect PrefillNewsletterCampaignEmailOnNewsletterScheduled where
  reflectName = "PrefillNewsletterCampaignEmailOnNewsletterScheduled"

instance IsProcess PrefillNewsletterCampaignEmailOnNewsletterScheduled NewsletterScheduled Payload where
  async = true

  handleEvent payload = do
    n <- now

    let
      (Instant i) = payload.scheduledFor
      (Milliseconds ms) = Base.unInstant i

    when (ms > n) (queueCommand $ Command.PrefillNewsletterCampaignEmail { newsletterId: payload.id })
