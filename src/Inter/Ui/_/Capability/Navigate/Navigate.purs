module Inter.Ui.Capability.Navigate.Navigate where

import Proem hiding ((/))

import Control.Alt ((<|>))
import Core.Mod.Article.Slug.Slug (Slug, unsafeFromString)
import Core.Mod.MagazineIssue.Slug.Slug as MagazineIssueSlug
import Core.Mod.Article.Theme.Theme (Theme) as ArticleTheme
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name as Author

import Core.Mod.Html.Html as Html
import Data.Either (Either(..), note)

import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..), isNothing)
import Data.Profunctor (dimap)
import Data.Show.Generic (genericShow)
import Effect (Effect)
import Foreign (unsafeToForeign)
import Inter.Api.Social.Meta.Type (Meta, defaultDescription, defaultMeta, defaultTitle)
import Routing.Duplex (RouteDuplex', as, optional, params, path, print, root, segment)
import Routing.Duplex.Generic (noArgs, product, sum)
import Routing.Duplex.Generic.Syntax ((/))
import Run (EFFECT, Run)
import Run as Run
import Yoga.JSON as Yoga.JSON
import Type.Row (type (+))
import Util.Html.Dom.Dom (setMetaContent, setMetaRobotsDefault)
import Util.Type.String.ToString (toString, fromString)
import Web.HTML (window)
import Web.HTML.HTMLDocument (setTitle)
import Web.HTML.History (DocumentTitle(..), URL(..), pushState)
import Web.HTML.Window (document, history)

foreign import _dispatchPopStateEvent :: Effect Ɩ

type MenuParams =
  { search ::
      { openWith :: Maybe String
      , withAuthorFilter :: Maybe { id :: AuthorId, name :: Author.Name, ofBook :: Boolean }
      }
  , magazineIssueOpen :: Maybe MagazineIssueSlug.Slug
  }

type Params =
  { menu :: MenuParams
  , consumeMagicLoginToken :: Maybe String
  }

data Route
  = Home Params
  | Theme ArticleTheme.Theme Params
  | Article Slug Params
  | Donate Params
  | NotFound

derive instance Generic Route _
derive instance Eq Route
derive instance Ord Route

menuSearchCodec :: RouteDuplex' String -> RouteDuplex' { openWith :: Maybe String, withAuthorFilter :: Maybe { id :: AuthorId, name :: Author.Name, ofBook :: Boolean } }
menuSearchCodec = as toString' fromString'
  where
  toString' { openWith, withAuthorFilter } = Yoga.JSON.writeJSON { input: openWith, authorFilter: withAuthorFilter <#> \f -> { id: toString f.id, name: toString f.name, ofBook: f.ofBook } }
  fromString' s = case Yoga.JSON.readJSON s of
    Right (json :: { input :: Maybe String, authorFilter :: Maybe { id :: String, name :: String, ofBook :: Boolean } }) ->
      let
        filter = json.authorFilter >>= \f -> (fromString f.id) <#> \id -> { id, name: Html.unsafeFromString f.name, ofBook: f.ofBook }
      in
        Right { openWith: json.input, withAuthorFilter: filter }
    Left _ -> Left "Invalid Search JSON"

menuMagazineIssueCodec :: RouteDuplex' String -> RouteDuplex' MagazineIssueSlug.Slug
menuMagazineIssueCodec = as toString fromString'
  where
  fromString' s = Right (MagazineIssueSlug.unsafeFromString s)

routeCodec :: RouteDuplex' Route
routeCodec = root $ sum routeConfig
  where
  routeConfig =
    { "Home": dimap to from $ params
        { menuSearchOpenWith: optional ◁ menuSearchCodec
        , menuMagazineIssueOpen: optional ◁ menuMagazineIssueCodec
        , consumeMagicLoginToken: optional :: RouteDuplex' String -> RouteDuplex' (Maybe String)
        }
    , "Theme": path "theme" $ product (as toString (fromString ▷ note "Invalid Theme") segment) $ dimap to from $ params
        { menuSearchOpenWith: optional ◁ menuSearchCodec
        , menuMagazineIssueOpen: optional ◁ menuMagazineIssueCodec
        , consumeMagicLoginToken: optional :: RouteDuplex' String -> RouteDuplex' (Maybe String)
        }
    , "Article": product (as toString (Right ◁ unsafeFromString) segment) $ dimap to from $ params
        { menuSearchOpenWith: optional ◁ menuSearchCodec
        , menuMagazineIssueOpen: optional ◁ menuMagazineIssueCodec
        , consumeMagicLoginToken: optional :: RouteDuplex' String -> RouteDuplex' (Maybe String)
        }
    , "Donate": path "page" $ path "donate" $ dimap to from $ params
        { menuSearchOpenWith: optional ◁ menuSearchCodec
        , menuMagazineIssueOpen: optional ◁ menuMagazineIssueCodec
        , consumeMagicLoginToken: optional :: RouteDuplex' String -> RouteDuplex' (Maybe String)
        }
    , "NotFound": "404" / noArgs
    }

  to { consumeMagicLoginToken, menu: { search, magazineIssueOpen } } =
    { consumeMagicLoginToken
    , menuSearchOpenWith: if isNothing search.openWith && isNothing search.withAuthorFilter then Nothing else Just search
    , menuMagazineIssueOpen: magazineIssueOpen
    }

  from { consumeMagicLoginToken, menuSearchOpenWith, menuMagazineIssueOpen } =
    { consumeMagicLoginToken
    , menu:
        { search: case menuSearchOpenWith of
            Just s -> s
            Nothing -> { openWith: Nothing, withAuthorFilter: Nothing }
        , magazineIssueOpen: menuMagazineIssueOpen
        }
    }

routePath :: Route -> String
routePath = print routeCodec

instance Show Route where
  show = genericShow

data Navigate a
  = Navigate Route a
  | UpdateMeta (Maybe Meta) a

derive instance Functor Navigate

type NAVIGATE fx = (navigate :: Navigate | fx)

navigate' = π :: Π "navigate"

navigate_ :: ∀ fx. Route -> Run (NAVIGATE + fx) Ɩ
navigate_ route = Run.lift navigate' (Navigate route unit)

updateMeta_ :: ∀ fx. Maybe Meta -> Run (NAVIGATE + fx) Ɩ
updateMeta_ meta = Run.lift navigate' (UpdateMeta meta unit)

interpretNavigate :: ∀ fx. Run (NAVIGATE + EFFECT + fx) ~> Run (EFFECT + fx)
interpretNavigate = Run.interpret (Run.on navigate' handle Run.send)
  where
  handle :: ∀ a fx'. Navigate a -> Run (EFFECT + fx') a
  handle (Navigate route next) = do
    let
      path = routePath route

    ʌ $ do
      hist <- window >>= history
      pushState (unsafeToForeign {}) (DocumentTitle "") (URL path) hist
      _dispatchPopStateEvent

      setMetaRobotsDefault

    η next

  handle (UpdateMeta meta next) = do
    let
      mTitle = meta >>= _.title
      mDesc = meta >>= _.description
      title = (mTitle <|> defaultMeta.title) ??⇒ defaultTitle
      description = (mDesc <|> defaultMeta.description) ??⇒ defaultDescription

    ʌ $ do
      doc <- window >>= document

      setTitle title doc

      setMetaContent "description" description
      setMetaContent "og:title" title
      setMetaContent "og:description" description

    η next
