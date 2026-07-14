module Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Payload where

import Core.Mod.Article.Id.Message.Field.Id (Id, IdField)

type Payload =
  { article :: Id
  }

type Fields =
  (article :: IdField
  )
