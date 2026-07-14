module Inter.Ui.Mod.ArticleCard.HandleAction.Initialize
  (initialize
  ) where

import Proem

import Inter.Ui.Mod.ArticleCard.Type (ArticleCardM, Input)
import Inter.Ui.Capability.ArticleCache.Trans (putArticleCache)
import Util.Type.String.ToString (toString)

initialize :: Input -> ArticleCardM Ɩ
initialize input = do
  when (toString input.article.slug /= "") $ putArticleCache (toString input.article.slug)
    { slug: input.article.slug
    , title: input.article.title
    , bookAuthors: input.article.bookAuthors
    , author: input.article.author
    , lead: input.article.lead
    , illustration: do
        ill <- input.article.illustration
        dims <- ill.dimensions
        η { src: ill.src, dimensions: dims, caption: ill.caption, isFallback: ill.isFallback }
    }
