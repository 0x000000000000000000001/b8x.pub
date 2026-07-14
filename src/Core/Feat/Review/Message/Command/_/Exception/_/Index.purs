module Core.Feat.Review.Message.Command.Exception.Index where

import Core.Feat.Review.Message.Command.WriteArticle.Exception.Index (WriteArticleExceptionRow)
import Core.Feat.Review.Message.Command.AddNewsTopic.Exception.Index (AddNewsTopicExceptionRow)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Exception.Index (AddArticleToNewsRelatedWhitelistExceptionRow)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Exception.Index (AddArticleToNewsRelatedBlacklistExceptionRow)
import Core.Feat.Review.Message.Command.TrackArticleRead.Exception.Index (TrackArticleReadExceptionRow)
import Type.Row (type (+))

type ReviewCommandExceptionRow r =
  WriteArticleExceptionRow
    + AddNewsTopicExceptionRow
    + AddArticleToNewsRelatedWhitelistExceptionRow
    + AddArticleToNewsRelatedBlacklistExceptionRow
    + TrackArticleReadExceptionRow
    + r