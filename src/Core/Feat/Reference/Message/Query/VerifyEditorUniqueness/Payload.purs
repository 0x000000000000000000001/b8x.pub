module Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Payload where

import Core.Mod.Editor.Name.Message.Field (Name, NameField)

type Fields =
  ( name ∷ NameField
  )

type Payload =
  { name ∷ Name
  }
