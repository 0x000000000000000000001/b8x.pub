module Core.Mod.Article.Illustrations.Message.Query.Build where

import Proem

import Core.Message.Query.Payload as Payload
import Core.Message.Query.Result (Return(..)) as Result
import Core.Mod.Article.Illustrations.Message.Query.Opt (IllustrationsOpt, IllustrationsInnerNeeds)
import Core.Mod.Article.Projection.Illustrations (Illustrations) as Projection
import Core.Mod.Article.Projection.Books.Books (Books) as Projection
import Core.Mod.Image.Image (Image(..)) as Projection
import Data.Array as Array
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.Number as Number
import Core.Mod.Html.Html (NonEmptyHtml)
import Core.Message.Query.Handle (build)
import Core.Mod.Image.Message.Query.Result (Illustration) as Result
import Core.Mod.Image.Message.Query.Build (buildImage)
import Core.Mod.Html.Url (absolutizeOurObjectStorageUrls, relativizeCleanOurUrls)

type Illustration =
  { image :: Projection.Image
  , caption :: Maybe NonEmptyHtml
  , isFallback :: Boolean
  }

buildIllustration :: String -> IllustrationsOpt -> IllustrationsInnerNeeds -> Illustration -> Result.Illustration
buildIllustration urlBase _ innerNeeds ill =
  let
    treatUrls h = relativizeCleanOurUrls $ absolutizeOurObjectStorageUrls h
  in
    { image: case innerNeeds.image of
        Payload.NotNeeded -> Result.NotGivenBecauseNotNeeded
        Payload.Needed imgOpt imgInnerNeeds -> Result.Given (buildImage urlBase imgOpt imgInnerNeeds ill.image)
    , caption: build innerNeeds.caption (ill.caption <#> treatUrls)
    , isFallback: build innerNeeds.isFallback ill.isFallback
    }

buildIllustrations
  :: ∀ r
   . Payload.Need IllustrationsOpt IllustrationsInnerNeeds
  -> Projection.Illustrations
  -> Projection.Books
  -> (IllustrationsOpt -> IllustrationsInnerNeeds -> Illustration -> r)
  -> Result.Return (Array r)
buildIllustrations Payload.NotNeeded _ _ _ = Result.NotGivenBecauseNotNeeded
buildIllustrations (Payload.Needed opt innerNeeds) ills books f = Result.Given $
  let
    rawIlls = (unwrap ills).illustrations <#> \i -> { image: i.image, caption: i.caption, isFallback: false }
    rawBooks = (unwrap books).books
    bookCovers = Array.catMaybes $ rawBooks <#> \b -> b.cover <#> \c -> { image: c, caption: Nothing, isFallback: true }
    illsToUse = if Array.length rawIlls == 0 then (if opt.fallbackToBookCovers then bookCovers else rawIlls) else rawIlls

    sortedIlls = case opt.priorizeRatio of
      Just targetRatio ->
        Array.sortBy
          ( comparing \{ image: Projection.Image img } ->
              Number.abs (Int.toNumber img.dimensions.width / Int.toNumber img.dimensions.height - targetRatio)
          )
          illsToUse
      Nothing -> illsToUse
  in
    sortedIlls <#> f opt innerNeeds
