module Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Exception.Index where

import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Exception.ArticleCannotBeAddedToNewsRelatedBlacklist (ArticleCannotBeAddedToNewsRelatedBlacklistRow)
import Type.Row (type (+))

type AddArticleToNewsRelatedBlacklistExceptionRow r =
  ArticleCannotBeAddedToNewsRelatedBlacklistRow
    + r
