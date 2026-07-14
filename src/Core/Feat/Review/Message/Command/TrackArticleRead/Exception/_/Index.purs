module Core.Feat.Review.Message.Command.TrackArticleRead.Exception.Index where

import Core.Feat.Review.Message.Command.TrackArticleRead.Exception.ArticleReadCannotBeTracked (ArticleReadCannotBeTrackedRow)
import Type.Row (type (+))

type TrackArticleReadExceptionRow r =
  ArticleReadCannotBeTrackedRow
    + r
