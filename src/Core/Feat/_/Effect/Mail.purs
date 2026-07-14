module Core.Feat.Effect.Mail
  ( MAIL
  , Mail(..)
  , mail'
  , sendMagicLink
  ) where

import Proem

import Core.Mod.Email.Email (Email)
import Run (Run, lift)
import Type.Row (type (+))

data Mail a = SendMagicLink Email String String (Ɩ -> a)

derive instance Functor Mail

type MAIL fx = (mail :: Mail | fx)

mail' = π :: Π "mail"

sendMagicLink :: ∀ fx. Email -> String -> String -> Run (MAIL + fx) Ɩ
sendMagicLink email token returnTo = lift mail' (SendMagicLink email token returnTo identity)
