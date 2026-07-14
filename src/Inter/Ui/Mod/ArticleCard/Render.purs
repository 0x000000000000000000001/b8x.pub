module Inter.Ui.Mod.ArticleCard.Render
  (render
  ) where

import Proem hiding (div)

import CSS (block)
import Inter.Ui.Mod.ArticleCard.Util (truncateLead)
import Data.Array as Array
import Data.Maybe (Maybe(..), fromMaybe)
import Halogen (ComponentHTML)
import Halogen.HTML (text)
import Halogen.HTML.Properties (alt, src)
import Util.Html.Clean.Render.Render as CleanRender
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Mod.ArticleCard.Style as Style
import Inter.Ui.Mod.ArticleCard.Type (Action(..), Slots, State)
import Inter.Ui.Mod.Link.Component (link_)
import Inter.Ui.UiM (UiM)
import Util.File.Image.Common (transparentPlaceholder)
import Util.Type.Limit (Limit(..))
import Data.Newtype (unwrap)
import Util.Type.String.ToString (toString)

render :: State -> ComponentHTML Action Slots UiM
render state =
  let
    id = state.id
    input = state.input
    isTextOnly = input.hiddenIllustration || case input.article.illustration of
      Just ill -> ill.src == ""
      Nothing -> true
  in
    link_ @"link"
      ({ route: if toString input.article.slug /= "" then Just $ Article input.article.slug { consumeMagicLoginToken: Nothing, menu: { magazineIssueOpen: Nothing, search: { openWith: Nothing, withAuthorFilter: Nothing } } } else Nothing
        , classes: Just
            $ Array.catMaybes
                [ Just Style.linkClass
                , if input.popOnHover then Just Style.popOnHoverClass else Nothing
                , if input.baseShadow then Just Style.baseShadowClass else Nothing
                ]
        , display: block
        , children:
            [ Style.sheet id input.scale
            , Style.articleCard_ id input.scale isTextOnly
                [ if input.loading then
                    Style.illustrationWrapper input.hiddenIllustration []
                      [ Style.illustration true false [ src transparentPlaceholder ] ]
                  else case input.article.illustration of
                    Just ill | ill.src /= "" ->
                      let
                        isPortraitOrSquare = case ill.dimensions of
                          Just dims -> dims.width <= dims.height
                          Nothing -> false
                      in
                        if isPortraitOrSquare then
                          Style.illustrationWrapper input.hiddenIllustration []
                            [ Style.illustrationBlur [ src ill.src, alt "" ]
                            , Style.illustrationContain [ src ill.src, alt (unwrap input.article.title) ]
                            ]
                        else
                          Style.illustrationWrapper input.hiddenIllustration []
                            [ Style.illustration false false [ src ill.src, alt (unwrap input.article.title) ] ]
                    _ ->
                      text ""
                , if input.loading then
                    Style.author_ true [ text "Loading author" ]
                  else
                    let
                      authorsToDisplay = case Array.length input.article.bookAuthors of
                        0 -> case input.article.author of
                          Just aa -> [ aa.name ]
                          Nothing -> []
                        _ -> input.article.bookAuthors
                    in
                      if Array.length authorsToDisplay > 0 then
                        Style.author_ false (Array.intercalate [text ", "] (map (\a -> CleanRender.renderArray a) authorsToDisplay))
                      else
                        text ""
                , if input.loading then
                    Style.title_ true
                      [ text "Loading title"
                      ]
                  else if unwrap input.article.title /= "" then
                    Style.title_ false [ CleanRender.render input.article.title ]
                  else
                    text ""
                , if input.loading then
                    Style.lead_ true
                      [ text "Loading lead..."
                      , text "Loading lead..."
                      , text "Loading lead..."
                      ]
                  else if fromMaybe "" (map unwrap input.article.lead.lead) /= "" then
                    let
                      finalLead = case input.maxChars of
                        Just m -> truncateLead (Finite m) (fromMaybe (CleanRender.SanitizedHtmlString "") input.article.lead.lead)
                        _ -> fromMaybe (CleanRender.SanitizedHtmlString "") input.article.lead.lead
                    in
                      Style.lead_ false [ CleanRender.render finalLead ]
                  else
                    text ""
                ]
            ]
        }
      )
      HandleLinkOutput
      ""
