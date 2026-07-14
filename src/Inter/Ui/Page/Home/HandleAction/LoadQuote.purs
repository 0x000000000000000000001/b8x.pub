module Inter.Ui.Page.Home.HandleAction.LoadQuote
  ( loadQuote
  ) where

import Core.Mod.Article.Content.Excerpt.CutStrategy (CutStrategy(..), Suffix(..), SuffixValue(..))
import Proem

import Core.Feat.Review.Message.Query.GetArticleQuote.Query (GetArticleQuote(..))
import Inter.Ui.Page.Home.Type (HomeM, _articleQuote)
import Inter.Ui.Remote (queryModify')
import Core.Message.Query.Payload (Need(..), Fold(..))
import Util.Html.Clean.Clean (TagList(..))
import Core.Mod.Article.Title.Clean as TitleClean
import Core.Mod.Article.Lead.Clean as LeadClean
import Core.Mod.Book.Cover.Message.Query.Opt (defaultCoverOpt)
import Data.Maybe (Maybe(..))
import Network.RemoteData (RemoteData(..))
import Inter.Ui.Capability.ArticleCache.Trans (putArticleCache)
import Util.Type.String.ToString (toString)
import Data.Array as Array
import Core.Message.Query.Result as QueryResult
import Inter.Ui.Page.Home.Util (cleanNonEmpty, cleanNonEmptyStripTags)
import Inter.Ui.Capability.ArticleCache.ArticleCache (extractRequiredCacheValue, extractOptionalCacheValue)
import Halogen (get)

loadQuote :: HomeM Ɩ
loadQuote = do
  st <- get

  ø $ queryModify' identity handleResult _articleQuote
    ( GetArticleQuote
        { theme: st.input.theme
        , needs:
            { id: NotNeeded
            , title: Needed
                { untagHtml:
                    { whitelist: TitleClean.defaultUntagWhitelist
                    , blacklistInWhitelist: Tags []
                    }
                }
                ι
            , lead: Needed
                { fallbackToContentExcerpt: Just { cutStrategy: OnSentenceEnd { min: 200, max: 300, suffix: OnlyOnHardSentenceCut Default }, newlineReplacement: Just " " }
                , untagHtml:
                    { whitelist: LeadClean.defaultUntagWhitelist
                    , blacklistInWhitelist: Tags []
                    }
                }
                { isFallback: Needed ι ι
                }
            , illustrations: Needed
                { priorizeRatio: Just (16.0 / 9.0)
                , fallbackToBookCovers: true
                }
                { image: Needed ι
                    { src: Needed { absolute: true } ι
                    , dimensions: Needed ι { width: Needed ι ι, height: Needed ι ι }
                    }
                , caption: Needed ι ι
                , isFallback: Needed ι ι
                }
            , books: Needed (Unfolded ι) $ Unfolded
                { id: NotNeeded
                , name: Needed ι ι
                , year: NotNeeded
                , cover: Needed defaultCoverOpt { src: Needed { absolute: true } ι, dimensions: NotNeeded }
                , authors: Needed ι ι
                , editor: Needed ι ι
                }
            , author: Needed ι
                { id: Needed ι ι
                , name: Needed ι ι
                , biography: NotNeeded
                , portrait: Needed ι { src: Needed { absolute: true } ι, dimensions: NotNeeded }
                }
            , slug: NotNeeded
            }
        }
    )
  where
  handleResult (Success (Just { article, slug })) = do
    putArticleCache (toString slug)
      { slug: slug
      , title: cleanNonEmpty (extractRequiredCacheValue article.title)
      , bookAuthors: case extractRequiredCacheValue article.books of
          QueryResult.Unfolded bks -> bks >>= \b -> extractRequiredCacheValue b.authors <#> \a -> cleanNonEmptyStripTags a.name
          _ -> []
      , author: extractOptionalCacheValue article.author <#> \a ->
          { id: toString (extractRequiredCacheValue a.id)
          , name: cleanNonEmptyStripTags (extractRequiredCacheValue a.name)
          }
      , lead:
          let
            l = extractRequiredCacheValue article.lead
          in
            { lead: extractOptionalCacheValue l.lead <#> cleanNonEmpty
            , isFallback: extractRequiredCacheValue l.isFallback
            }
      , illustration: case Array.head (extractRequiredCacheValue article.illustrations) of
          Nothing -> Nothing
          Just ill ->
            let
              image = extractRequiredCacheValue ill.image
              dims = extractRequiredCacheValue image.dimensions
              w = extractRequiredCacheValue dims.width
              h = extractRequiredCacheValue dims.height
              src = extractRequiredCacheValue image.src
              isFallback = extractRequiredCacheValue ill.isFallback
              caption = extractOptionalCacheValue ill.caption <#> cleanNonEmpty
            in
              Just { src: src, dimensions: { width: w, height: h }, caption: caption, isFallback: isFallback }
      }
  handleResult _ = pure unit
