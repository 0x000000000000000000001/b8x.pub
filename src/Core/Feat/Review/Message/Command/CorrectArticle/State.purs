module Core.Feat.Review.Message.Command.CorrectArticle.State where

import Core.Feat.Review.Message.Command.CorrectArticle.Payload as CorrectArticle
import Core.Mod.Article.Content.Content (Content)
import Core.Mod.Article.Lead.Lead (Lead)
import Core.Mod.Article.State as Article
import Core.Mod.Article.Title.Title (Title)

type ArticleData =
  { title :: Title
  , lead :: Lead
  , content :: Content
  }

type State =
  { article :: Article.State ArticleData
  }

initialState :: CorrectArticle.Payload -> State
initialState _ =
  { article: Article.initialState
  }
