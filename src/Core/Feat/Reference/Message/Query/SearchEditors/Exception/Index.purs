module Core.Feat.Reference.Message.Query.SearchEditors.Exception.Index where

import Core.Feat.Reference.Message.Query.SearchEditors.Exception.InvalidEditorFilter (InvalidEditorFilterRow)

type SearchEditorsQueryExceptionRow r =
  ( | InvalidEditorFilterRow r
  )
