module Inter.Ui.Router.Menu.HandleAction.GoToNewsletterArticles where

import Proem

import Core.Mod.Time.Month (Month)
import Core.Mod.Time.Year (Year)
import Data.Lens ((.~))
import Halogen (modify_, fork)

import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Router.Menu.Type.State.State (_newsletter)
import Inter.Ui.Router.Menu.Type.State.Newsletter as Newsletter
import Inter.Ui.Router.Menu.Type.State.Newsletter (_articles, _page)
import Inter.Ui.Remote (queryModify)
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Query (ListNewsletterArticles(..))
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Field.Newsletter as NewsletterField
import Inter.Ui.Page.Home.Util (bandArticleNeeds)
import Core.Mod.Article.Content.Excerpt.CutStrategy (CutStrategy(..), Suffix(..), SuffixValue(..))
import Core.Message.Query.Payload (Need(..))
import Util.Html.Clean.Clean (TagList(..), untagAll)
import Core.Mod.Article.Lead.Clean as LeadClean
import Data.Maybe (Maybe(..))
import Inter.Ui.Router.Menu.HandleAction.Util.Scroll (scrollTopMenu)
import Record as Record
import Type.Proxy (Proxy(..))
import Network.RemoteData (RemoteData(..))
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Result (Article)
import Data.Foldable (for_)
import Core.Message.Query.Result as QueryResult
import Util.Type.String.ToString as Util.Type.String.ToString
import Util.Html.Clean.Render.Render (sanitizeHtml)
import Data.Newtype (unwrap)
import Inter.Ui.Capability.ArticleCache.Trans (putArticleCache)
import Data.Array as Array
import Inter.Ui.Capability.ArticleCache.ArticleCache (extractRequiredCacheValue, extractOptionalCacheValue)
import Core.Mod.Newsletter.Id.Id (NewsletterId)

goToNewsletterArticles :: Year -> Month -> Maybe NewsletterId -> Boolean -> MenuM Ɩ
goToNewsletterArticles year month mId fromShortcut = do
  modify_ (_newsletter ◁ _page .~ Newsletter.Articles { year, month, fromShortcut })

  scrollTopMenu

  let
    newsletter = case mId of
      Just id -> NewsletterField.Id id
      Nothing -> NewsletterField.Month { year, month }

  ø
    $ queryModify
        ( \res -> case res of
            Success { articles } -> ø $ fork $ cacheNewsletterArticles articles
            _ -> ηι
        )
        (_newsletter ◁ _articles)
    $ ListNewsletterArticles
        { blacklist: []
        , needs: Record.delete (Proxy @"magazineIssuePageNumber") $ Record.delete (Proxy @"magazineSection") $ Record.insert (Proxy @"newsletters") (Needed ι ι) $ Record.delete (Proxy @"onFrontPages") $ Record.delete (Proxy @"seoUpdatedAt") (bandArticleNeeds { lead = Needed { fallbackToContentExcerpt: Just { cutStrategy: OnSentenceEnd { min: 200, max: 300, suffix: OnlyOnHardSentenceCut Default }, newlineReplacement: Just " ¶ " }, untagHtml: { whitelist: LeadClean.defaultUntagWhitelist, blacklistInWhitelist: Tags [] } } { isFallback: Needed ι ι } })
        , newsletter
        , illustrationRequired: false
        }

cacheNewsletterArticles :: Array Article -> MenuM Ɩ
cacheNewsletterArticles articles = for_ articles \art -> do
  let
    slugVal = extractRequiredCacheValue art.slug
    titleVal = sanitizeHtml (unwrap (extractRequiredCacheValue art.title))

    bookAuthors = case extractRequiredCacheValue art.books of
      QueryResult.Unfolded bks -> bks >>= \b -> extractRequiredCacheValue b.authors <#> \a -> sanitizeHtml (untagAll false (unwrap a.name))
      _ -> []

    articleAuthorTxt = extractOptionalCacheValue art.author <#> \a ->
      { id: Util.Type.String.ToString.toString (extractRequiredCacheValue a.id), name: sanitizeHtml (untagAll false (unwrap (extractRequiredCacheValue a.name))) }

    leadVal =
      let
        l = extractRequiredCacheValue art.lead
      in
        { lead: extractOptionalCacheValue l.lead <#> \h -> sanitizeHtml (unwrap h)
        , isFallback: extractRequiredCacheValue l.isFallback
        }

    illustrations = extractRequiredCacheValue art.illustrations

    firstIll = Array.head illustrations

    imageVal = case firstIll of
      Just ill ->
        let
          isFb = extractRequiredCacheValue ill.isFallback
          illCaption = extractOptionalCacheValue ill.caption <#> \cap -> sanitizeHtml (unwrap cap)
          image = extractRequiredCacheValue ill.image
          dims = extractRequiredCacheValue image.dimensions
          w = extractRequiredCacheValue dims.width
          h = extractRequiredCacheValue dims.height
          src = extractRequiredCacheValue image.src
        in
          Just { src: src, dimensions: { width: w, height: h }, caption: illCaption, isFallback: isFb }
      Nothing -> Nothing

  when (Util.Type.String.ToString.toString slugVal /= "") $ putArticleCache (Util.Type.String.ToString.toString slugVal)
    { slug: slugVal
    , title: titleVal
    , bookAuthors: bookAuthors
    , author: articleAuthorTxt
    , lead: leadVal
    , illustration: imageVal
    }
