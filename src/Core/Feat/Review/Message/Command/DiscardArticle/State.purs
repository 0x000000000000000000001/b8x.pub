module Core.Feat.Review.Message.Command.DiscardArticle.State where

import Proem

import Core.Feat.Review.Message.Command.DiscardArticle.Payload as DiscardArticle
import Core.Mod.Article.State as Article

type State = Article.State Ɩ

initialState :: DiscardArticle.Payload -> State
initialState _ = Article.initialState
