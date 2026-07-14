module Inter.Api.Whitelist.Query where

import Core.Feat.Membership.Message.Query.GetUserAccount.Query (GetUserAccount)
import Core.Feat.Reference.Message.Query.SearchAuthors.Query (SearchAuthors)
import Core.Feat.Reference.Message.Query.SearchBooks.Query (SearchBooks)
import Core.Feat.Reference.Message.Query.SearchEditors.Query (SearchEditors)
import Core.Feat.Review.Message.Query.GetFrontPage.Query (GetFrontPage)
import Core.Feat.Review.Message.Query.GetArticle.Query (GetArticle)
import Core.Feat.Review.Message.Query.GetArticleQuote.Query (GetArticleQuote)
import Core.Feat.Review.Message.Query.SearchArticles.Query (SearchArticles)
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Query (SearchNewsletters)
import Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Query (ListNewsRelatedArticles)
import Core.Feat.Review.Message.Query.ListMostReadArticles.Query (ListMostReadArticles)
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Query (ListNewsletterArticles)
import Core.Feat.Reference.Message.Query.SearchMagazineIssues.Query (SearchMagazineIssues)
import Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Query (SearchMagazineCustomSections)
import Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Query (GetNewsletterCalendar)
import Core.Feat.Reference.Message.Query.GetMagazineCalendar.Query (GetMagazineCalendar)
import Core.Feat.Reference.Message.Query.GetAuthor.Query (GetAuthor)
import Core.Feat.Sitemap.Message.Query.ListArticleYears.Query (ListArticleYears)
import Core.Feat.Sitemap.Message.Query.ListYearArticles.Query (ListYearArticles)
import Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Query (ListMagazineIssues)

type QueryRow =
  ( getArticle :: GetArticle
  , getArticleQuote :: GetArticleQuote
  , getAuthor :: GetAuthor
  , getFrontPage :: GetFrontPage
  , getNewsletterCalendar :: GetNewsletterCalendar
  , getMagazineCalendar :: GetMagazineCalendar
  , getUserAccount :: GetUserAccount
  , listNewsRelatedArticles :: ListNewsRelatedArticles
  , listArticleYears :: ListArticleYears
  , listYearArticles :: ListYearArticles
  , listMagazineIssues :: ListMagazineIssues
  , listMostReadArticles :: ListMostReadArticles
  , listNewsletterArticles :: ListNewsletterArticles
  , searchArticles :: SearchArticles
  , searchAuthors :: SearchAuthors
  , searchBooks :: SearchBooks
  , searchEditors :: SearchEditors
  , searchMagazineIssues :: SearchMagazineIssues
  , searchMagazineCustomSections :: SearchMagazineCustomSections
  , searchNewsletters :: SearchNewsletters
  )
