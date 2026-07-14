module Core.Feat.Reference.Message.Command.DereferenceEditor.Payload where

import Core.Mod.Editor.Id.Message.Field.Editor (Editor, EditorField)

type Payload =
  { editor :: Editor
  }

type Fields =
  (editor :: EditorField
  )
