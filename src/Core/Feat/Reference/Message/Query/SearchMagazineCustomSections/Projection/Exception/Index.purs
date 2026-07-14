module Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Exception.Index where

import Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Exception.InvalidCustomSectionFilter (InvalidCustomSectionFilterRow)
import Type.Row (type (+))

type SearchMagazineCustomSectionsExceptionRow r =
  InvalidCustomSectionFilterRow
    + r
