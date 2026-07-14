module Core.Feat.Newsletter.Message.Command.AddNewsletterSubscriber.Payload where

import Core.Mod.Email.Message.Field (Email, EmailField)

type Payload =
  { email :: Email
  }

type Fields =
  (email :: EmailField
  )
