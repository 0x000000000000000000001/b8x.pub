module Core.Feat.Membership.Message.Command.TrackUserDonated.Payload where

import Core.Mod.Email.Message.Field (Email, EmailField)
import Core.Mod.Time.Message.Field.Instant (Instant, InstantField)
import Core.Feat.Membership.Message.Command.TrackUserDonated.Field.Amount (AmountField, Amount)

type Payload =
  { email :: Email
  , donatedAt :: Instant
  , amount :: Amount
  }

type Fields =
  ( email :: EmailField
  , donatedAt :: InstantField
  , amount :: AmountField
  )
