module Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.Decide where

import Proem

import Core.Event.Event (Event)
import Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.Payload (Payload)
import Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.State (State)
import Run (Run)
import Type.Row (type (+))
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Message.Command.Handle.Download (DOWNLOAD)
import Core.Message.Command.Handle.Upload (UPLOAD)

decide :: ∀ fx. State -> Payload -> Run (EXCEPT_LOGIC + DOWNLOAD
           + UPLOAD + fx) (Array Event)
decide _ _ = η []
