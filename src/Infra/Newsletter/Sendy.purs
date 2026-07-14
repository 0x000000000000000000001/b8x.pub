module Infra.Newsletter.Sendy
  ( interpretNewsletter
  ) where

import Proem

import Core.Feat.Effect.Newsletter (NEWSLETTER, Newsletter(..), newsletter')
import Infra.Client.Sendy as SendyClient
import Infra.Client.Mailchimp.Mailchimp as MailchimpClient
import Run (AFF, EFFECT, Run, interpret, on, send)
import Type.Row (type (+))

interpretNewsletter
  :: ∀ fx a
   . Run (NEWSLETTER + EFFECT + AFF + SendyClient.READER_SENDY_CONFIG + MailchimpClient.READER_MAILCHIMP_CONFIG + fx) a
  -> Run (EFFECT + AFF + SendyClient.READER_SENDY_CONFIG + MailchimpClient.READER_MAILCHIMP_CONFIG + fx) a
interpretNewsletter = interpret (on newsletter' handle send)
  where
  handle :: ∀ fx' a'. Newsletter a' -> Run (EFFECT + AFF + SendyClient.READER_SENDY_CONFIG + MailchimpClient.READER_MAILCHIMP_CONFIG + fx') a'
  handle (AddSubscriber email next) = do
    SendyClient.addSubscriber email
    η $ next ι
  handle (PrefillCampaign _newsletterId campaignName subject schedule articles next) = do
    modifiedHtml <- MailchimpClient.getPrefilledMasterTemplateHtml articles
    SendyClient.createCampaign 
      { title: campaignName
      , subject: subject
      , htmlText: modifiedHtml
      , sendRightaway: false
      , scheduledFor: schedule
      }
    η $ next ι
