module Core.Feat.Review.Message.Command.AddNewsTopic.Exception.Index where

import Core.Feat.Review.Message.Command.AddNewsTopic.Exception.NewsTopicCannotBeAdded (NewsTopicCannotBeAddedRow)
import Core.Mod.NewsTopic.Exception.TooManyNewsTopicsAdded (TooManyNewsTopicsAddedRow)
import Type.Row (type (+))

type AddNewsTopicExceptionRow r =
  NewsTopicCannotBeAddedRow
    + TooManyNewsTopicsAddedRow
    + r
