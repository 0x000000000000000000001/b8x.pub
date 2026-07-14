module Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.Command
  ( PrefillNewsletterCampaignEmail(..)
  ) where

import Core.Mod.Article.Content.Excerpt.CutStrategy (defaultSuffixValue, CutStrategy(..), Suffix(..), SuffixValue(..))
import Proem
import Core.Mod.Article.Content.Message.Query.Opt (defaultContentOpt)

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultResult)
import Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.Payload (Fields, Payload)
import Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.Result (Result)
import Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.State (State, initialState)
import Core.Feat.Effect.Newsletter (PrefillArticle, prefillCampaign)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Either (Either(..))
import Util.Type.Random (class Random)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype, unwrap)
import Util.Type.Type (class Reflect, reflectConstructorName)
import Core.Feat.Effect.Generate (now)
import Core.Mod.Time.Instant (Instant(..), toHumanParisDate, toSendyScheduleDate)
import Data.DateTime.Instant as Base
import Data.Time.Duration (Milliseconds(..))
import Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.Filter (filter)
import Util.Html.Clean.Clean (TagList(..), untagAll)
import Core.Mod.Article.Title.Clean as TitleClean
import Core.Mod.Article.Lead.Clean as LeadClean
import Util.Type.String.String (removeAccents)
import Core.Message.Query.Payload (Fold(..), Need(..))
import Core.Event.EventStore (loadEvents)
import Core.Feat.Newsletter.Message.Command.PrefillNewsletterCampaignEmail.Play (play)
import Core.Mod.Newsletter.State as Newsletter
import Data.Array (foldl, find, mapMaybe, elem, head)
import Core.Mod.Article.Content.Excerpt.Excerpt (findSentenceEnd, truncateInnerTextThenHealOuterHtml)
import Data.Tuple (Tuple(..))
import Util.Html.Encode.Encode (decodeHtmlEntities)
import Util.Type.Limit (Limit(..))
import Data.Array as Array
import Core.Message.Query.Handle (handleQuery)
import Core.Feat.Review.Message.Query.SearchArticles.Query (SearchArticles(..))
import Core.Feat.Review.Message.Query.SearchArticles.Projection.Projection (ArticleFilter(..))
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit(..))
import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation(..))
import Core.Message.Query.Result (Return(..))
import Core.Message.Query.Result (Fold(..)) as Result
import Data.Maybe (Maybe(..))
import Core.Mod.Html.Html (NonEmptyHtml(..))
import Core.Mod.Book.Year.Year (Year(..))
import Data.String (joinWith, length, take, toLower, Pattern(..), split)
import Data.Enum (fromEnum)
import Core.Mod.Book.Cover.Message.Query.Opt (defaultCoverOpt)
import Config.PublicConfig (publicConfig, toAbsolute_)
import Inter.Ui.Capability.Navigate.Navigate (Route(..), routeCodec)
import Routing.Duplex (print)

newtype PrefillNewsletterCampaignEmail = PrefillNewsletterCampaignEmail Payload

derive instance Newtype PrefillNewsletterCampaignEmail _
derive instance Generic PrefillNewsletterCampaignEmail _
derive newtype instance Random PrefillNewsletterCampaignEmail
derive newtype instance WriteForeign PrefillNewsletterCampaignEmail
derive newtype instance ReadForeign PrefillNewsletterCampaignEmail

instance Reflect PrefillNewsletterCampaignEmail where
  reflectName = reflectConstructorName @PrefillNewsletterCampaignEmail

instance IsProtectedAgainstConcurrency PrefillNewsletterCampaignEmail where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    PrefillNewsletterCampaignEmail
    State
    Fields
    Payload
    Result
  where
  description = "Prefill Mailchimp campaign for newsletter"

  handle payload = do
    loadedEvents <- loadEvents (filter payload)
    let state = foldl play (initialState payload) loadedEvents

    case state of
      Newsletter.Scheduled { scheduledFor: Instant i, articles } -> do
        n <- now
        let (Milliseconds ms) = Base.unInstant i
        if ms > n then do
          let
            searchFilter = foldl
              ( \acc id -> case acc of
                  Nothing -> Just $ ArticleHasId id
                  Just f -> Just $ ArticleOr { left: f, right: ArticleHasId id }
              )
              Nothing
              articles

            query = SearchArticles
              { sort: []
              , filter: searchFilter
              , expectation: QuickNothingBetterThanSlowerSomething
              , limit: BoundedLimit 6
              , after: Nothing
              , needs:
                  { id: Needed ι ι
                  , legacyId: NotNeeded
                  , title: Needed { untagHtml: { whitelist: TitleClean.defaultUntagWhitelist, blacklistInWhitelist: Tags [] } } ι
                  , lead: Needed { fallbackToContentExcerpt: Just { cutStrategy: OnSentenceEnd { min: 800, max: 1000, suffix: OnlyOnHardSentenceCut Default }, newlineReplacement: Just " " }, untagHtml: { whitelist: appendLinkTag LeadClean.defaultUntagWhitelist, blacklistInWhitelist: Tags [] } } { isFallback: NotNeeded }
                  , notes: NotNeeded
                  , sources: NotNeeded
                  , content: Needed defaultContentOpt { untagHtml = { whitelist: appendLinkTag LeadClean.defaultUntagWhitelist, blacklistInWhitelist: Tags [] } } ι
                  , theme: NotNeeded
                  , books: Needed (Unfolded ι) $ Unfolded
                      { id: NotNeeded
                      , name: Needed ι ι
                      , year: Needed ι ι
                      , cover: Needed defaultCoverOpt { src: Needed { absolute: true } ι, dimensions: NotNeeded }
                      , authors: Needed ι ι
                      , editor: Needed ι ι
                      }
                  , author: Needed ι
                      { id: NotNeeded
                      , name: Needed ι ι
                      , biography: NotNeeded
                      , portrait: NotNeeded
                      }
                  , illustrations: Needed { priorizeRatio: Just $ 16.0 / 9.0, fallbackToBookCovers: true } { image: Needed ι { src: Needed { absolute: true } ι, dimensions: NotNeeded }, caption: NotNeeded, isFallback: NotNeeded }
                  , slug: Needed ι ι
                  , magazineSection: NotNeeded
                  , magazineIssuePageNumber: NotNeeded
                  , seoUpdatedAt: NotNeeded
                  , onFrontPages: NotNeeded
                  }
              }

          res <- handleQuery query

          let
            orderedArticles = mapMaybe
              ( \id -> find
                  ( \a -> case a.id of
                      Given articleId -> articleId == id
                      _ -> false
                  )
                  res.articles
              )
              articles

            prefillArticles :: Array PrefillArticle
            prefillArticles = Array.mapWithIndex
              ( \index a ->
                  let
                    title = case a.title of
                      Given (NonEmptyHtml t) -> untagAll false t
                      _ -> ""
                    lead = case a.lead of
                      Given l -> case l.lead of
                        Given (Just (NonEmptyHtml rawHtml)) ->
                          let
                            html =
                              if index == 5 then
                                case head (split (Pattern "<a ") rawHtml) of
                                  Just firstPart -> firstPart
                                  Nothing -> rawHtml
                              else
                                rawHtml

                            str = untagAll false html
                            minB = if index == 5 then 500 else 800
                            maxB = if index == 5 then 700 else 1000
                          in
                            if index == 5 || length str <= maxB then html
                            else
                              let
                                Tuple limit isHardCut = findSentenceEnd minB maxB (decodeHtmlEntities str)
                                suffix = if isHardCut then defaultSuffixValue else ""
                              in
                                truncateInnerTextThenHealOuterHtml (Finite limit) suffix html
                        _ -> ""
                      _ -> ""
                    extract = case a.content of
                      Given (NonEmptyHtml rawHtml) ->
                        let
                          html =
                            if index == 5 then
                              case head (split (Pattern "<a ") rawHtml) of
                                Just firstPart -> firstPart
                                Nothing -> rawHtml
                            else
                              rawHtml

                          str = untagAll false html
                          minB = if index == 5 then 500 else 800
                          maxB = if index == 5 then 700 else 1000
                        in
                          if index == 5 || length str <= maxB then html
                          else
                            let
                              Tuple limit isHardCut = findSentenceEnd minB maxB (decodeHtmlEntities str)
                              suffix = if isHardCut then defaultSuffixValue else ""
                            in
                              truncateInnerTextThenHealOuterHtml (Finite limit) suffix html
                      _ -> ""
                    authorName = case a.author of
                      Given (Just authorData) -> case authorData.name of
                        Given (NonEmptyHtml authorNameHtml) -> untagAll false authorNameHtml
                        _ -> ""
                      _ -> ""

                    booksData = case a.books of
                      Given (Result.Unfolded bs) ->
                        let
                          names = bs <#> \b -> case b.name of
                            Given (NonEmptyHtml bookNameHtml) -> untagAll false bookNameHtml
                            _ -> ""
                          authors = bs <#> \b -> case b.authors of
                            Given auths -> joinWith ", " (auths <#> \author -> let (NonEmptyHtml authorNameHtml2) = author.name in untagAll false authorNameHtml2)
                            _ -> ""
                          years = bs <#> \b -> case b.year of
                            Given (Just (Year y)) -> (y.approximately ? "vers " ↔ "") <> show (fromEnum (unwrap y.year))
                            _ -> ""
                          editors = bs <#> \b -> case b.editor of
                            Given (Just (NonEmptyHtml editorNameHtml)) -> untagAll false editorNameHtml
                            _ -> ""
                          prefix = case head bs of
                            Just b -> case b.authors of
                              Given auths -> case head auths of
                                Just author ->
                                  let
                                    (NonEmptyHtml authorNameHtml2) = author.name
                                    name = untagAll false authorNameHtml2
                                    firstChar = removeAccents (toLower (take 1 name))
                                  in
                                    if elem firstChar [ "a", "e", "i", "o", "u", "y", "h" ] then "d'" else "de "
                                Nothing -> "de "
                              _ -> ""
                            Nothing -> ""
                          covers = bs <#> \b -> case b.cover of
                            Given (Just cOpt) -> case cOpt.src of
                              Given src -> src
                              _ -> ""
                            _ -> ""
                          cover = case head covers of
                            Just c -> c
                            Nothing -> ""
                        in
                          { names, authors, years, editors, prefix, cover }
                      _ -> { names: [], authors: [], years: [], editors: [], prefix: "", cover: "" }
                  in
                    let
                      illustrationUrl = case a.illustrations of
                        Given ills -> case Array.head ills of
                          Just ill -> case ill.image of
                            Given img -> case img.src of
                              Given src -> src
                              _ -> ""
                            _ -> ""
                          Nothing -> ""
                        _ -> ""
                      link = case a.slug of
                        Given slug -> toAbsolute_ publicConfig.ui.host (print routeCodec (Article slug { consumeMagicLoginToken: Nothing, menu: { search: { openWith: Nothing, withAuthorFilter: Nothing }, magazineIssueOpen: Nothing } }))
                        _ -> ""
                    in
                      { title
                      , lead
                      , extract
                      , authorName
                      , bookNames: booksData.names
                      , bookAuthors: booksData.authors
                      , bookEditors: booksData.editors
                      , bookYears: booksData.years
                      , bookPrefix: booksData.prefix
                      , link: link
                      , keywords: []
                      , illustrationUrl: illustrationUrl
                      , bookCoverUrl: booksData.cover
                      }
              )
              orderedArticles

          let campaignName = "La Booksletter. Autogénérée (le " <> toHumanParisDate (Instant i) <> ", heure de Paris)"
          let subject = "La Booksletter"
          let scheduledForStr = Just (toSendyScheduleDate (Instant i))
          ø $ prefillCampaign payload.newsletterId campaignName subject scheduledForStr prefillArticles
          η $ Right $ defaultResult ι
        else do
          η $ Right $ defaultResult ι
      _ ->
        η $ Right $ defaultResult ι

appendLinkTag :: TagList -> TagList
appendLinkTag All = All
appendLinkTag (Tags t) = Tags (t <> [ "a" ])
