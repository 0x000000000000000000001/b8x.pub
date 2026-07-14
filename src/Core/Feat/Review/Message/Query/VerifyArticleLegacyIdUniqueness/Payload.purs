module Core.Feat.Review.Message.Query.VerifyArticleLegacyIdUniqueness.Payload where

import Core.Mod.Article.LegacyId.Message.Field (LegacyId, LegacyIdField)

type Payload =
  { legacyId :: LegacyId
  }

type Fields :: Row Type
type Fields =
  ( legacyId :: LegacyIdField
  )
