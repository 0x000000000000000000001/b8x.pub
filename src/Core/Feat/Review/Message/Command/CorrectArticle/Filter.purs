module Core.Feat.Review.Message.Command.CorrectArticle.Filter where

import Proem hiding ((&&), (||))

import Core.Event.ArticleContentCorrected.ArticleContentCorrected (ArticleContentCorrected)
import Core.Event.ArticleLeadCorrected.ArticleLeadCorrected (ArticleLeadCorrected)
import Core.Event.ArticleTitleCorrected.ArticleTitleCorrected (ArticleTitleCorrected)
import Core.Event.Filter (Filter(..), by)
import Core.Feat.Review.Message.Command.CorrectArticle.Payload (Payload)
import Core.Mod.Article.State as Article

filter :: Payload -> Filter
filter { id } =
  Or (Article.filter id)
    ( Or (by @ArticleTitleCorrected @"article" id)
        (Or (by @ArticleLeadCorrected @"article" id) (by @ArticleContentCorrected @"article" id))
    )
