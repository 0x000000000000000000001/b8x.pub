module Inter.Ui.Mod.ArticleCard.HandleAction.Receive
  (receive
  ) where

import Proem

import Halogen (modify_)
import Inter.Ui.Mod.ArticleCard.Type (ArticleCardM, Input)
import Inter.Ui.Capability.ArticleCache.Trans (putArticleCache)
import Util.Type.String.ToString (toString)

receive :: Input -> ArticleCardM Ɩ
receive input = do
  modify_ \st -> st { input = input }
  when (toString input.article.slug /= "") $ putArticleCache (toString input.article.slug)
    { slug: input.article.slug
    , title: input.article.title
    , bookAuthors: input.article.bookAuthors
    , author: input.article.author
    , lead: input.article.lead
    , illustration: do
        ill <- input.article.illustration
        dims <- ill.dimensions
        pure { src: ill.src, dimensions: dims, caption: ill.caption, isFallback: ill.isFallback }
    }
