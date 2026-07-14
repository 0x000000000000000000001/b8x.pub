module Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Exception.Index where

import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Exception.ArticleCannotBeAddedToNewsRelatedWhitelist (ArticleCannotBeAddedToNewsRelatedWhitelistRow)
import Core.Mod.Article.Exception.TooManyArticlesAddedToNewsRelatedWhitelist (TooManyArticlesAddedToNewsRelatedWhitelistRow)
import Type.Row (type (+))

type AddArticleToNewsRelatedWhitelistExceptionRow r =
  ArticleCannotBeAddedToNewsRelatedWhitelistRow
    + TooManyArticlesAddedToNewsRelatedWhitelistRow
    + r
