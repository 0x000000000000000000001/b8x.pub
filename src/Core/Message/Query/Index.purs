module Core.Message.Query.Index where

import Core.Feat.Membership.Message.Query.Index (MembershipQueryRow)
import Core.Feat.Reference.Message.Query.Index (ReferenceQueryRow)
import Core.Feat.Review.Message.Query.Index (ReviewQueryRow)
import Core.Feat.Newsletter.Message.Query.Index (NewsletterQueryRow)
import Core.Feat.Sitemap.Message.Query.Index (SitemapQueryRow)
import Data.Variant (Variant)
import Type.Row (type (+))

type Query = Variant QueryRow

type QueryRow =
  MembershipQueryRow
    + ReferenceQueryRow
    + ReviewQueryRow
    + NewsletterQueryRow
    + SitemapQueryRow
    + ()
