module Core.Feat.Exception.Index where

import Core.Message.Exception.Index (MessageExceptionRow)
import Core.Feat.Membership.Exception.Index (MembershipExceptionRow)
import Core.Feat.Newsletter.Exception.Index (NewsletterExceptionRow)
import Core.Feat.Reference.Exception.Index (ReferenceExceptionRow)
import Core.Feat.Review.Exception.Index (ReviewExceptionRow)
import Type.Row (type (+))

type FeatExceptionRow e r =
  MembershipExceptionRow
    + MessageExceptionRow e
    + NewsletterExceptionRow
    + ReferenceExceptionRow
    + ReviewExceptionRow
    + r
