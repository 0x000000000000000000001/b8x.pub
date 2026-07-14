module Inter.Ui.Router.Menu.Core.Items.Items where

import Proem hiding (div)

import Data.Maybe (Maybe(..), isJust, fromMaybe)
import Halogen (ComponentHTML)
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Router.Menu.Core.Items.Item.Item (item)
import Inter.Ui.Router.Menu.Core.Items.Separator.Separator (separator)
import Inter.Ui.Router.Menu.Core.Items.Style.Style as Style
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.UiM (UiM)
import Core.Mod.Article.Theme.Theme (Theme(..)) as ArticleTheme
import Util.I18n (Language(..), translate)
import Halogen.HTML (div, text)
import Halogen.HTML.Core (AttrName(..), ClassName(..))
import Halogen.HTML.Properties (attr) as Hattr
import Util.Html.Clean.Render.Render (SanitizedHtmlString(..), render)
import Inter.Ui.Router.Menu.Core.Items.Item.Style.Style as ItemStyle
import Inter.Ui.Router.Menu.Core.Items.Item.Label.Style as LabelStyle
import Inter.Ui.Mod.Link.Component (link_)
import Data.Tuple.Nested ((/\))
import CSS as CSS

items :: State -> ComponentHTML Action Slots UiM
items state = Style.items_ state items'
  where
  items' :: Array (ComponentHTML Action Slots UiM)
  items' =
    renderItems homeItems
      <> [ separator ]
      <> renderItems themeItems
      <> [ separator ]
      <> renderItems archiveItems
      <> [ separator, giftItem state ]
      <>
        ( if isJust state.me then
            [ separator ] <> renderItems [ { label: "Me déconnecter", route: Nothing, action: Just Logout } ]
          else
            [ separator ] <> renderItems [ { label: "Me connecter", route: Nothing, action: Just OpenLoginModal } ]
        )

  renderItems :: Array Item -> Array (ComponentHTML Action Slots UiM)
  renderItems = map \{ label, route, action } -> item label route action

type Item =
  { label :: String
  , route :: Maybe Route
  , action :: Maybe Action
  }

homeItems ∷ Array Item
homeItems =
  [ { label: "Accueil"
    , route: Just $ Home { consumeMagicLoginToken: Nothing, menu: { magazineIssueOpen: Nothing, search: { openWith: Nothing, withAuthorFilter: Nothing } } }
    , action: Nothing
    }
  ]

makeThemeRoute :: ArticleTheme.Theme -> Maybe Route
makeThemeRoute theme = Just $ Theme theme { consumeMagicLoginToken: Nothing, menu: { magazineIssueOpen: Nothing, search: { openWith: Nothing, withAuthorFilter: Nothing } } }

makeThemeItem :: ArticleTheme.Theme -> Item
makeThemeItem theme = { label: translate Fr theme, route: makeThemeRoute theme, action: Nothing }

themeItems ∷ Array Item
themeItems =
  [ makeThemeItem ArticleTheme.History
  , makeThemeItem ArticleTheme.Politics
  , makeThemeItem ArticleTheme.Ideas
  , makeThemeItem ArticleTheme.Literature
  , makeThemeItem ArticleTheme.Science
  ]

archiveItems ∷ Array Item
archiveItems =
  [ { label: "Newsletters", route: Nothing, action: Just OpenNewsletter }
  , { label: "Magazines", route: Nothing, action: Just OpenMagazine }
  ]

giftSvg :: String
giftSvg = """<svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-gift"><rect x="3" y="8" width="18" height="4" rx="1"></rect><path d="M12 8v13"></path><path d="M19 12v7a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2v-7"></path><path d="M7.5 8a2.5 2.5 0 0 1 0-5A4.8 8 0 0 1 12 8a4.8 8 0 0 1 4.5-5 2.5 2.5 0 0 1 0 5"></path></svg>"""

giftItem :: State -> ComponentHTML Action Slots UiM
giftItem state =
  let
    hasPaid = fromMaybe false (state.me <#> _.membership.hasPaidLastYear)
  in
    if hasPaid then
      HH.a
        [ HP.href "https://www.helloasso.com/associations/les-amis-de-books/collectes/relancons-la-booksletter-3"
        , HP.target "_blank"
        , HP.classes [ ClassName ItemStyle.staticClass ]
        , Hattr.attr (AttrName "style") "display: flex; text-decoration: none; color: inherit;"
        ]
        [ LabelStyle.label
            [ Hattr.attr (AttrName "style") "display: flex; align-items: center; justify-content: flex-start;" ]
            [ div [ Hattr.attr (AttrName "style") "width: 2.2rem; height: 2.2rem; margin-top: 0.5rem; margin-right: 0.8rem; display: flex; align-items: center; justify-content: center; flex-shrink: 0;" ]
                [ render (SanitizedHtmlString giftSvg) ]
            , div [] [ text "Faire un don" ]
            ]
        ]
    else
      let
        route = Donate { consumeMagicLoginToken: Nothing, menu: { magazineIssueOpen: Nothing, search: { openWith: Nothing, withAuthorFilter: Nothing } } }
      in
        link_
          @"items"
          { route: Just route
          , classes: Just [ ItemStyle.staticClass ]
          , display: CSS.flex
          , children:
              [ LabelStyle.label
                  [ Hattr.attr (AttrName "style") "display: flex; align-items: center; justify-content: flex-start;" ]
                  [ div [ Hattr.attr (AttrName "style") "width: 2.2rem; height: 2.2rem; margin-top: 0.5rem; margin-right: 0.8rem; display: flex; align-items: center; justify-content: center; flex-shrink: 0;" ]
                      [ render (SanitizedHtmlString giftSvg) ]
                  , div [] [ text "Faire un don" ]
                  ]
              ]
          }
          HandleLinkOutput
          ("Faire un don" /\ Just route)
