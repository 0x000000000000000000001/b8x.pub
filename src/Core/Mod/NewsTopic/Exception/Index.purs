module Core.Mod.NewsTopic.Exception.Index where

import Core.Mod.NewsTopic.Exception.NewsTopicNotAdded (NewsTopicNotAddedRow)
import Type.Row (type (+))

type NewsTopicExceptionRow r =
  NewsTopicNotAddedRow
    + r
