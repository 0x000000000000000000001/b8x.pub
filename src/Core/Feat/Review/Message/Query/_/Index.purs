module Core.Feat.Review.Message.Query.Index where

import Core.Feat.Review.Message.Query.GetFrontPage.Query (GetFrontPage)
import Core.Feat.Review.Message.Query.GetArticle.Query (GetArticle)
import Core.Feat.Review.Message.Query.SearchArticles.Query (SearchArticles)
import Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Query (ListNewsRelatedArticles)
import Core.Feat.Review.Message.Query.ListMostReadArticles.Query (ListMostReadArticles)
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Query (ListNewsletterArticles)
import Core.Feat.Review.Message.Query.VerifyNewsTopicLimit.Query (VerifyNewsTopicLimit)
import Core.Feat.Review.Message.Query.VerifyArticleLegacyIdUniqueness.Query (VerifyArticleLegacyIdUniqueness)
import Core.Feat.Review.Message.Query.VerifyNewsRelatedArticleWhitelistLimit.Query (VerifyNewsRelatedArticleWhitelistLimit)

type ReviewQueryRow r =
  ( getFrontPage :: GetFrontPage
  , getArticle :: GetArticle
  , searchArticles :: SearchArticles
  , listNewsRelatedArticles :: ListNewsRelatedArticles
  , listMostReadArticles :: ListMostReadArticles
  , listNewsletterArticles :: ListNewsletterArticles
  , verifyNewsTopicLimit :: VerifyNewsTopicLimit
  , verifyArticleLegacyIdUniqueness :: VerifyArticleLegacyIdUniqueness
  , verifyNewsRelatedArticleWhitelistLimit :: VerifyNewsRelatedArticleWhitelistLimit
  | r
  )