module Core.Feat.Review.Message.Command.WriteArticle.Exception.Index where

import Core.Feat.Review.Message.Command.WriteArticle.Exception.ArticleCannotBeWritten (ArticleCannotBeWrittenRow)
import Core.Mod.Article.LegacyId.Exception.LegacyIdAlreadyTaken (LegacyIdAlreadyTakenRow)
import Type.Row (type (+))

type WriteArticleExceptionRow r =
  ArticleCannotBeWrittenRow
    + LegacyIdAlreadyTakenRow
    + r
