module Core.Feat.Review.Message.Query.GetArticleQuote.State where

import Core.Feat.Review.Message.Query.GetArticleQuote.Payload as GetArticleQuote

type State = {}

initialState :: GetArticleQuote.Payload -> State
initialState _ = {}
