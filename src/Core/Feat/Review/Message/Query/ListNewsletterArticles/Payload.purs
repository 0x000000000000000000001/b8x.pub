module Core.Feat.Review.Message.Query.ListNewsletterArticles.Payload where

import Core.Feat.Review.Message.Query.ListNewsletterArticles.Field.Blacklist (Blacklist, BlacklistField)
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Field.IllustrationRequired (IllustrationRequiredField, IllustrationRequired)
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Field.Needs (Needs, NeedsField)
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Field.Newsletter (Newsletter, NewsletterField)

type Fields
  = ( blacklist :: BlacklistField
    , needs :: NeedsField
    , newsletter :: NewsletterField
    , illustrationRequired :: IllustrationRequiredField
    )

type Payload
  = { blacklist :: Blacklist
    , needs :: Needs
    , newsletter :: Newsletter
    , illustrationRequired :: IllustrationRequired
    }
