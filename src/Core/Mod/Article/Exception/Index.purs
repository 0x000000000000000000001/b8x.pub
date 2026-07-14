module Core.Mod.Article.Exception.Index where

import Core.Mod.Article.Exception.ArticleAlreadyWritten (ArticleAlreadyWrittenRow)
import Core.Mod.Article.Exception.ArticleSlugAlreadyTaken (ArticleSlugAlreadyTakenRow)
import Core.Mod.Article.Exception.ArticleNotWritten (ArticleNotWrittenRow)
import Core.Mod.Article.FrontPage.Position.Exception (PositionExceptionRow)
import Core.Mod.Article.Identifier.Exception (IdentifierExceptionRow)
import Core.Mod.Article.Illustrations.Exception.Index (ArticleIllustrationExceptionRow)
import Core.Mod.Article.Projection.Exception.Index (ArticleProjectionExceptionRow)
import Core.Mod.Article.Slug.Exception (SlugExceptionRow)
import Core.Mod.Article.Theme.Exception (ThemeExceptionRow)
import Type.Row (type (+))

type ArticleExceptionRow r =
  ArticleIllustrationExceptionRow
    + ArticleProjectionExceptionRow
    + IdentifierExceptionRow
    + SlugExceptionRow
    + ArticleAlreadyWrittenRow
    + ArticleSlugAlreadyTakenRow
    + ArticleNotWrittenRow
    + PositionExceptionRow
    + SlugExceptionRow
    + ThemeExceptionRow
    + r