module Inter.Ui.Mod.Newsletter.HandleAction.Submit (submit) where

import Proem

import Core.Feat.Newsletter.Message.Command.AddNewsletterSubscriber.Command (AddNewsletterSubscriber(..))
import Core.Mod.Email.Email as Email
import Data.Either (Either(..))
import Halogen (gets, modify_)
import Web.Event.Event (Event, preventDefault)
import Inter.Ui.Mod.Newsletter.Type (NewsletterM, Status(..))
import Core.Feat.Newsletter.Message.Command.AddNewsletterSubscriber.Payload (Payload)
import Inter.Ui.Remote (command)
import Network.RemoteData as RD

submit :: Event -> NewsletterM Ɩ
submit event = do
  ʌ $ preventDefault event

  state <- gets identity

  case Email.make_ true state.email of
    Left _ -> do
      modify_ _ { status = InvalidEmail }
    Right email -> do
      modify_ _ { status = Submitting }

      let payload = { email } :: Payload
      res <- command (AddNewsletterSubscriber payload)

      case res of
        RD.Success _ -> modify_ _ { status = Success, email = "" }
        RD.Failure _ -> modify_ _ { status = Failure }
        _ -> η ι
