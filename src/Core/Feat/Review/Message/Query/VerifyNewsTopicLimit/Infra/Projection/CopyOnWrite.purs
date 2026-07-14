module Core.Feat.Review.Message.Query.VerifyNewsTopicLimit.Infra.Projection.CopyOnWrite where

import Proem
import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

verifyNewsTopicLimitProjectionWriteCopyState' = π :: Π "verifyNewsTopicLimitProjectionWriteCopyState"

type VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_WRITE_COPY_STATE fx = (verifyNewsTopicLimitProjectionWriteCopyState :: State CopyOnWrite | fx)

type VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_WRITE_COPY_PERSIST fx = (verifyNewsTopicLimitProjectionWriteCopyPersist :: ProjectionPersist | fx)
