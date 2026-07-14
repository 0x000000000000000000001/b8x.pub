module Core.Feat.Review.Message.Command.TrackArticleRead.State where

import Proem

import Core.Feat.Review.Message.Command.TrackArticleRead.Payload as TrackArticleRead
import Core.Mod.Article.State as Article

type State = Article.State Ɩ

initialState :: TrackArticleRead.Payload -> State
initialState _ = Article.initialState
