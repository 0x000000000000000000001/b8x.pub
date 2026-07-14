module Core.Feat.Review.Message.Command.TrackArticleRead.Payload where

import Core.Mod.Article.Id.Message.Field.Id (Id, IdField)

type Payload =
  { id :: Id
  }

type Fields =
  (id :: IdField
  )
