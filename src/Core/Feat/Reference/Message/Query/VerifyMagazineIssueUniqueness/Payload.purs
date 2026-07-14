module Core.Feat.Reference.Message.Query.VerifyMagazineIssueUniqueness.Payload where

import Core.Mod.MagazineIssue.Complement.Message.Field (Complement, ComplementField)
import Core.Mod.MagazineIssue.Number.Message.Field (IssueNumber, IssueNumberField)
import Core.Mod.MagazineIssue.Special.Message.Field (Special, SpecialField)

type Payload =
  { number :: IssueNumber
  , special :: Special
  , complement :: Complement
  }

type Fields =
  ( number :: IssueNumberField
  , special :: SpecialField
  , complement :: ComplementField
  )
