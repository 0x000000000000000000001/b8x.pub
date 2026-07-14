module Core.Feat.Process.Index
  (Process
  , ProcessRow
  ) where

import Core.Feat.Membership.Process.Index (MembershipProcessRow)
import Core.Feat.Newsletter.Process.Index (NewsletterProcessRow)
import Data.Variant (Variant)
import Type.Row (type (+))

type Process = Variant ProcessRow

type ProcessRow =
  MembershipProcessRow
    + NewsletterProcessRow
    + ()
