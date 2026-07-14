module Infra.Mail.Ses.Mail where

import Proem

import Config.PublicConfig (READER_PUBLIC_CONFIG, toUiAbsolute)
import Core.Feat.Effect.Mail (MAIL, Mail(..), mail')
import Infra.Client.Aws.Ses.Ses (READER_SES_CLIENT, sendTransactionalMail)
import Run (AFF, EFFECT, Run, interpret, on, send)
import Type.Row (type (+))
import Util.Type.String.ToString (toString)
import Data.String as String

interpretMail :: ∀ fx a. Run (MAIL + READER_PUBLIC_CONFIG + READER_SES_CLIENT + EFFECT + AFF + fx) a -> Run (READER_PUBLIC_CONFIG + READER_SES_CLIENT + EFFECT + AFF + fx) a
interpretMail = interpret (on mail' handle send)
  where
  handle :: ∀ fx' a'. Mail a' -> Run (READER_PUBLIC_CONFIG + READER_SES_CLIENT + EFFECT + AFF + fx') a'
  handle (SendMagicLink email token returnTo next) = do
    let
      separator = if String.contains (String.Pattern "?") returnTo then "&" else "?"
      magicLinkPath = returnTo <> separator <> "consumeMagicLoginToken=" <> token
    link <- toUiAbsolute magicLinkPath
    let
      to = { email: toString email, name: "" }
      subject = "Votre lien de connexion magique"
      text = "Bonjour,\n\nVoici votre lien de connexion magique : " <> link <> "\n\nSi vous n'avez pas demandé ce lien, vous pouvez ignorer cet email."
      html = "<p>Bonjour,</p><p>Voici votre lien de connexion magique : <a href=\"" <> link <> "\">" <> link <> "</a></p><p>Si vous n'avez pas demandé ce lien, vous pouvez ignorer cet email.</p>"

    _ <- sendTransactionalMail { to, subject, text, html }
    η $ next ι
