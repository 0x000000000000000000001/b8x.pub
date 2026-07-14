module Inter.Ui.Mod.ArticleCard.Util where

import Proem
import Core.Message.Query.Result (Fold(..), Return)
import Data.Array as Array
import Data.Maybe (Maybe(..), isJust)
import Inter.Ui.Mod.ArticleCard.Type (Article)
import Core.Mod.Article.Slug.Slug (Slug, unsafeFromString) as Slug
import Core.Mod.Article.Title.Title as Title
import Core.Mod.Article.Lead.Message.Query.Result as Lead
import Core.Mod.Author.Message.Query.Result as Author
import Core.Mod.Book.Message.Query.Result.Books as Books
import Core.Mod.Image.Message.Query.Result as Illustration
import Util.Html.Clean.Render.Render (SanitizedHtmlString(..), sanitizeHtml)
import Core.Mod.Article.Content.Excerpt.CutStrategy (defaultSuffixValue)
import Core.Mod.Article.Content.Excerpt.Excerpt (truncateInnerTextThenHealOuterHtml)
import Util.Type.Limit (Limit)
import Data.Newtype (unwrap)
import Util.Html.Clean.Clean (untagAll)
import Util.Type.String.ToString as Util.Type.String.ToString
import Inter.Ui.Capability.ArticleCache.ArticleCache (extractRequiredCacheValue, extractOptionalCacheValue)

emptyArticle :: Article
emptyArticle =
  { slug: Slug.unsafeFromString ""
  , title: SanitizedHtmlString ""
  , lead: { lead: Nothing, isFallback: false }
  , bookAuthors: []
  , author: Nothing
  , illustration: Nothing
  }

inputArticle
  :: ∀ r
   . { slug :: Return Slug.Slug
     , title :: Return Title.Title
     , lead :: Return Lead.Lead
     , author :: Return (Maybe Author.Author)
     , books :: Return Books.Books
     , illustrations :: Return (Array Illustration.Illustration)
     | r
     }
  -> Article
inputArticle art =
  let
    slug = extractRequiredCacheValue art.slug

    title = sanitizeHtml (unwrap (extractRequiredCacheValue art.title))

    lead =
      let
        l = extractRequiredCacheValue art.lead
      in
        { lead: extractOptionalCacheValue l.lead <#> \h -> sanitizeHtml (unwrap h), isFallback: extractRequiredCacheValue l.isFallback }

    articleAuthorTxt = extractOptionalCacheValue art.author <#> \a ->
      { id: Util.Type.String.ToString.toString (extractRequiredCacheValue a.id), name: sanitizeHtml (untagAll false (unwrap (extractRequiredCacheValue a.name))) }

    bookAuthors = case extractRequiredCacheValue art.books of
      Unfolded bks -> case Array.head bks of
        Just b ->
          let
            names = map (\a -> sanitizeHtml (untagAll false (unwrap a.name))) (extractRequiredCacheValue b.authors)
          in
            if Array.length names > 2 then case Array.take 2 names of
              [ (SanitizedHtmlString a1), (SanitizedHtmlString a2) ] -> [ SanitizedHtmlString a1, SanitizedHtmlString (a2 <> defaultSuffixValue) ]
              other -> other
            else
              names
        _ -> []
      _ -> []

    illustration = case Array.head (extractRequiredCacheValue art.illustrations) of
      Just ill ->
        let
          isFb = extractRequiredCacheValue ill.isFallback
          illCaption = extractOptionalCacheValue ill.caption <#> \c -> sanitizeHtml (unwrap c)
          image = extractRequiredCacheValue ill.image
          dims = extractRequiredCacheValue image.dimensions
          w = extractRequiredCacheValue dims.width
          h = extractRequiredCacheValue dims.height
          src = extractRequiredCacheValue image.src
        in
          Just { src, dimensions: Just { width: w, height: h }, caption: illCaption, isFallback: isFb }
      Nothing -> Nothing
  in
    { slug
    , title
    , lead
    , bookAuthors
    , author: articleAuthorTxt
    , illustration
    }

inputUiArticle
  :: ∀ r r2 r3 aId aBookId
   . Util.Type.String.ToString.ToString aId
  => { slug :: Return Slug.Slug
     , title :: Return SanitizedHtmlString
     , lead :: Return { lead :: Return (Maybe SanitizedHtmlString), isFallback :: Return Boolean }
     , author :: Return (Maybe { id :: Return aId, name :: Return SanitizedHtmlString | r2 })
     , books :: Return (Fold (Array aBookId) (Array { authors :: Return (Array { name :: SanitizedHtmlString | r3 }) | r }))
     , illustrations :: Return (Array { image :: Return Illustration.Image, caption :: Return (Maybe SanitizedHtmlString), isFallback :: Return Boolean })
     | r
     }
  -> Article
inputUiArticle art =
  let
    slug = extractRequiredCacheValue art.slug

    title = extractRequiredCacheValue art.title

    lead =
      let
        l = extractRequiredCacheValue art.lead
      in
        { lead: extractOptionalCacheValue l.lead, isFallback: extractRequiredCacheValue l.isFallback }

    articleAuthorTxt = extractOptionalCacheValue art.author <#> \a ->
      { id: Util.Type.String.ToString.toString (extractRequiredCacheValue a.id), name: extractRequiredCacheValue a.name }

    bookAuthors = case extractRequiredCacheValue art.books of
      Unfolded bks -> case Array.head bks of
        Just b ->
          let
            names = map (\a -> a.name) (extractRequiredCacheValue b.authors)
          in
            if Array.length names > 2 then case Array.take 2 names of
              [ (SanitizedHtmlString a1), (SanitizedHtmlString a2) ] -> [ SanitizedHtmlString a1, SanitizedHtmlString (a2 <> defaultSuffixValue) ]
              other -> other
            else
              names
        _ -> []
      _ -> []

    illustration = case Array.head (extractRequiredCacheValue art.illustrations) of
      Just ill ->
        let
          isFb = extractRequiredCacheValue ill.isFallback
          illCaption = extractOptionalCacheValue ill.caption
          image = extractRequiredCacheValue ill.image
          dims = extractRequiredCacheValue image.dimensions
          w = extractRequiredCacheValue dims.width
          h = extractRequiredCacheValue dims.height
          src = extractRequiredCacheValue image.src
        in
          Just { src, dimensions: Just { width: w, height: h }, caption: illCaption, isFallback: isFb }
      Nothing -> Nothing
  in
    { slug
    , title
    , lead
    , bookAuthors
    , author: articleAuthorTxt
    , illustration
    }

computeMaxChars :: Boolean -> Article -> Int
computeMaxChars hiddenIllustration article =
  let
    hasIllustration =
      not hiddenIllustration
        && case article.illustration of
          Just ill -> ill.src /= ""
          Nothing -> false

    hasAuthors = Array.length article.bookAuthors > 0 || isJust article.author
  in
    case hasIllustration, hasAuthors of
      true, true -> 200
      true, false -> 220
      false, true -> 400
      false, false -> 420

truncateLead :: Limit Int -> SanitizedHtmlString -> SanitizedHtmlString
truncateLead limit (SanitizedHtmlString str) = SanitizedHtmlString (truncateInnerTextThenHealOuterHtml limit defaultSuffixValue str)
