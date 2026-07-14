module Core.Mod.Id.Message.Field.AutoId where

import Proem

import Core.Message.MakeMessageM (generateUlid)
import Core.Message.Field.Field (Presence(..), Sanitized(..), defaultSanitize)
import Core.Mod.Id.Id (Id, unsafeFromString)
import Foreign (Foreign)

presence :: ∀ a. Presence (Id a)
presence =
  Optional
    (unsafeFromString <$> generateUlid)
    "Generated"

sanitize :: ∀ a. Foreign -> Sanitized (Id a)
sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault
