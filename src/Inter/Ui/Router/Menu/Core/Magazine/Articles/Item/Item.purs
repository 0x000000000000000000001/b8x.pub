module Inter.Ui.Router.Menu.Core.Magazine.Articles.Item.Item where

import Proem hiding (div)

import CSS (flex)
import CSS.Text.Transform (textTransform, uppercase)
import Core.Message.Query.Result (Return(..))
import Core.Feat.Review.Message.Query.SearchArticles.Result (Article)
import Core.Mod.MagazineIssue.Section.Section (SectionF(..))
import Data.Maybe (Maybe(..))
import Halogen (ComponentHTML)
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Mod.Link.Component (link_)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Style.Style (staticClass)
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.UiM (UiM)
import Util.Type.String.ToString (toString)
import Halogen.HTML (text, div)
import Halogen.HTML.CSS (style)
import CSS as CSS
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Style.Style (core_)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Title.Style (title_)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Section.Style (section_)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Content.Style (content_)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Thumb.Thumb (thumb)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Thumb.Style (Format(..))
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Thumb.Type (Thumb)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.TextWithMatchingWords (textWithMatchingWords)
import Data.Array as Array
import Data.Int as Int
import Util.Html.Clean.Render.Render (render, sanitizeHtml)
import Data.Newtype (unwrap)

item :: String -> Article -> ComponentHTML Action Slots UiM
item uniquePrefix article =
  link_ @"magazineArticles"
    { route: case article.slug of
        Given s -> Just $ Article s { consumeMagicLoginToken: Nothing, menu: { magazineIssueOpen: Nothing, search: { openWith: Nothing, withAuthorFilter: Nothing } } }
        _ -> Nothing
    , classes: Just [ staticClass ]
    , display: flex
    , children:
        ( case extractThumb article of
            Just t -> [ thumb t ]
            Nothing -> []
        ) <>
          [ core_
              [ case article.magazineSection of
                  Given (Just Intro) -> section_ [ text "Edito" ]
                  Given (Just FeatureIntro) -> section_ [ text "Edito du dossier" ]
                  Given (Just Feature) -> section_ [ text "Dossier" ]
                  Given (Just (Custom s)) -> section_ [ render (sanitizeHtml (unwrap s)) ]
                  _ -> text ""
              , case article.title of
                  Given t -> title_ [ textWithMatchingWords [] (toString t) ]
                  _ -> text ""
              , case article.lead of
                  Given l -> case l.lead of
                    Given h -> content_ [ textWithMatchingWords [] (toString h) ]
                    _ -> text ""
                  _ -> text ""
              , case article.magazineIssuePageNumber of
                  Given (Just p) ->
                    div
                      [ style do
                          CSS.fontWeight CSS.bold
                          CSS.fontSize (CSS.rem 0.75)
                          CSS.color (CSS.rgba 0 0 0 0.5)
                          textTransform uppercase
                          CSS.letterSpacing (CSS.rem 0.05)
                          CSS.marginTop (CSS.rem 0.33)
                      ]
                      [ text ("p. " <> toString p) ]
                  _ -> text ""
              ]
          ]
    }
    HandleLinkOutput
    ( "magazineArticle:" <> uniquePrefix <> ":" <>
        ( case article.slug of
            Given s -> toString s
            _ -> ""
        )
    )

extractThumb :: Article -> Maybe Thumb
extractThumb { illustrations } = case illustrations of
  Given ills -> case Array.head ills of
    Just
      { image:
          Given
            { src: Given src
            , dimensions: Given { width: Given width, height: Given height }
            }
      } ->
      let
        ratio = Int.toNumber width / Int.toNumber height
        format =
          if ratio > 1.05 then Landscape
          else if ratio < 0.95 then Portrait
          else Square
      in
        Just { src, format }
    _ -> Nothing
  _ -> Nothing
