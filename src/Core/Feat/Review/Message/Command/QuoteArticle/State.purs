module Core.Feat.Review.Message.Command.QuoteArticle.State where

import Proem

import Core.Feat.Review.Message.Command.QuoteArticle.Payload as QuoteArticle
import Core.Mod.Article.State as Article

type State = Article.State Ɩ

initialState :: QuoteArticle.Payload -> State
initialState _ = Article.initialState
