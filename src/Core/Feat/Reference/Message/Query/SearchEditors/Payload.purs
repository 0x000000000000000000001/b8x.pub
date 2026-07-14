module Core.Feat.Reference.Message.Query.SearchEditors.Payload where

import Core.Feat.Reference.Message.Query.SearchEditors.Projection.Message.Field.Filter (EditorFilterField, Filter)
import Core.Mod.Editor.Id.Message.Field.AfterEditor (AfterEditor, AfterEditorField)
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit)
import Core.Mod.Projection.Finder.BoundedLimit.Message.Field (BoundedLimitField)
import Core.Feat.Reference.Message.Query.SearchEditors.Field.Needs (Needs, NeedsField)
import Core.Mod.Projection.Finder.Expectation.Message.Field (Expectation, ExpectationField)

type Payload =
  { filter :: Filter
  , limit :: BoundedLimit
  , after :: AfterEditor
  , needs :: Needs
  , expectation :: Expectation
  }

type Fields =
  (filter :: EditorFilterField
  , limit :: BoundedLimitField
  , after :: AfterEditorField
  , needs :: NeedsField
  , expectation :: ExpectationField
  )
