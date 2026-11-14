module Core.Feat.Review.Message.Command.CorrectArticle.Payload where

import Core.Mod.Article.Content.Message.Field.CorrectedContent (CorrectedContent, CorrectedContentField)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Id.Message.Field.Article (ArticleField)
import Core.Mod.Article.Title.Message.Field.CorrectedTitle (CorrectedTitle, CorrectedTitleField)

type Payload =
  { id :: ArticleId
  , title :: CorrectedTitle
  , content :: CorrectedContent
  }

type Fields =
  ( id :: ArticleField
  , title :: CorrectedTitleField
  , content :: CorrectedContentField
  )
