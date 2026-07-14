module Core.Mod.Article.Projection.Exception.Index where

import Core.Mod.Article.Projection.Exception.InvalidArticleFilter (InvalidArticleFilterRow)
import Type.Row (type (+))

type ArticleProjectionExceptionRow r =
  InvalidArticleFilterRow
    + r