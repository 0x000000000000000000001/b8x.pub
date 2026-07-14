module Infra.Mail.Mock.Mail where


import Proem

import Core.Feat.Effect.Mail (MAIL, Mail(..), mail')
import Config.PublicConfig (READER_PUBLIC_CONFIG, toUiAbsolute)
import Effect.Console (log)
import Run (AFF, EFFECT, Run, interpret, on, send)
import Type.Row (type (+))
import Data.String as String

interpretMailWithMock :: ∀ fx a. Run (MAIL + READER_PUBLIC_CONFIG + EFFECT + AFF + fx) a -> Run (READER_PUBLIC_CONFIG + EFFECT + AFF + fx) a
interpretMailWithMock = interpret (on mail' handle send)
  where
  handle :: ∀ fx' a'. Mail a' -> Run (READER_PUBLIC_CONFIG + EFFECT + AFF + fx') a'
  handle (SendMagicLink email token returnTo next) = do
    let
      separator = if String.contains (String.Pattern "?") returnTo then "&" else "?"
      magicLinkPath = returnTo <> separator <> "consumeMagicLoginToken=" <> token
    link <- toUiAbsolute magicLinkPath
    ʌ $ log $ "[MOCK EMAIL] To: " <> show email <> "\n| Magic Link: " <> link
    η $ next ι
