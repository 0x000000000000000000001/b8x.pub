module Core.Feat.Newsletter.Message.Query.Index where

import Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Query (GetNewsletterCalendar)
import Core.Feat.Newsletter.Message.Query.VerifyNewsletterUniqueness.Query (VerifyNewsletterUniqueness)
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Query (SearchNewsletters)

type NewsletterQueryRow r =
  ( getNewsletterCalendar :: GetNewsletterCalendar
  , verifyNewsletterUniqueness :: VerifyNewsletterUniqueness
  , searchNewsletters :: SearchNewsletters
  | r
  )
