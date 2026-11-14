module Inter.Ui.Page.Article.HandleAction.Receive where

import Proem

import Halogen (gets, modify_)
import Inter.Ui.Page.Article.HandleAction.Load (load)
import Inter.Ui.Page.Article.Type (ArticleM, Input)
import Inter.Ui.Capability.ArticleCache.Trans (getArticleCache)
import Util.Type.String.ToString (toString)

receive :: Input -> ArticleM Ɩ
receive input = do
  oldInput <- gets _.input
  oldContext <- gets _.context
  
  when (oldContext /= input.context) $ do
    modify_ _ { context = input.context }

  when (oldInput /= input) $ do
    modify_ _ { input = input }

    when (oldInput.slug /= input.slug) $ do
      cached <- getArticleCache (toString input.slug)
      modify_ _ { cachedInfo = cached }
      load
