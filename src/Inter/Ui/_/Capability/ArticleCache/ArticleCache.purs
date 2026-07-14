module Inter.Ui.Capability.ArticleCache.ArticleCache where

import Proem

import Data.Array as Array
import Data.Maybe (Maybe(..))
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Foreign.Object (Object)
import Foreign.Object as Object
import Run (EFFECT, Run)
import Run as Run
import Type.Row (type (+))
import Core.Mod.Article.Slug.Slug (Slug)
import Util.Html.Clean.Render.Render (SanitizedHtmlString)
import Partial.Unsafe (unsafeCrashWith)
import Core.Message.Query.Result (Return(..))

extractRequiredCacheValue :: ∀ a. Return a -> a
extractRequiredCacheValue = case _ of
  Given x -> x
  NotGivenBecauseNotNeeded -> unsafeCrashWith "ArticleCache: Mandatory field was NotGivenBecauseNotNeeded! Add it to the Needs payload."
  NotGivenBecauseNotFound -> unsafeCrashWith "ArticleCache: Mandatory field was NotGivenBecauseNotFound!"
  NotGivenBecauseNotAuthorized -> unsafeCrashWith "ArticleCache: Mandatory field was NotGivenBecauseNotAuthorized!"

extractOptionalCacheValue :: ∀ a. Return (Maybe a) -> Maybe a
extractOptionalCacheValue = case _ of
  Given opt -> opt
  NotGivenBecauseNotNeeded -> unsafeCrashWith "ArticleCache: Optional field was NotGivenBecauseNotNeeded! Add it to the Needs payload."
  NotGivenBecauseNotFound -> Nothing
  NotGivenBecauseNotAuthorized -> Nothing

type CacheImage =
  { src :: String
  , dimensions :: { width :: Int, height :: Int }
  , caption :: Maybe SanitizedHtmlString
  , isFallback :: Boolean
  }

type CacheLead =
  { lead :: Maybe SanitizedHtmlString
  , isFallback :: Boolean
  }

type AlreadyKnown =
  { slug :: Slug
  , title :: SanitizedHtmlString
  , bookAuthors :: Array SanitizedHtmlString
  , author :: Maybe { id :: String, name :: SanitizedHtmlString }
  , lead :: CacheLead
  , illustration :: Maybe CacheImage
  }

type CacheState =
  { queue :: Array String
  , map :: Object AlreadyKnown
  }

data ArticleCache a
  = GetArticleCache String (Maybe AlreadyKnown -> a)
  | PutArticleCache String AlreadyKnown a

derive instance Functor ArticleCache

type ARTICLE_CACHE fx = (articleCache :: ArticleCache | fx)

articleCache' = π :: Π "articleCache"

getArticleCache_ :: ∀ fx. String -> Run (ARTICLE_CACHE + fx) (Maybe AlreadyKnown)
getArticleCache_ slug = Run.lift articleCache' (GetArticleCache slug identity)

putArticleCache_ :: ∀ fx. String -> AlreadyKnown -> Run (ARTICLE_CACHE + fx) Ɩ
putArticleCache_ slug known = Run.lift articleCache' (PutArticleCache slug known unit)

interpretArticleCache :: ∀ fx. Ref CacheState -> Run (ARTICLE_CACHE + EFFECT + fx) ~> Run (EFFECT + fx)
interpretArticleCache ref = Run.interpret (Run.on articleCache' handle Run.send)
  where
  handle :: ∀ a fx'. ArticleCache a -> Run (EFFECT + fx') a
  handle = case _ of
    GetArticleCache slug next -> do
      state <- ʌ $ Ref.read ref
      η $ next (Object.lookup slug state.map)

    PutArticleCache slug known next -> do
      ʌ $ Ref.modify_
        ( \state ->
            let
              newMap = Object.insert slug known state.map
              newQueue = Array.snoc (Array.filter (_ /= slug) state.queue) slug
            in
              if Array.length newQueue > 100 then case Array.uncons newQueue of
                Just { head, tail } -> { queue: tail, map: Object.delete head newMap }
                Nothing -> { queue: newQueue, map: newMap }
              else
                { queue: newQueue, map: newMap }
        )
        ref
      η next
