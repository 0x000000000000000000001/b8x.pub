module Inter.Ui.Page.Home.QuoteBlock.Render
  ( renderQuoteBlock
  ) where

import Proem hiding (div)

import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Inter.Ui.Page.Home.Type (Action(..), Slots, State)
import Inter.Ui.UiM (UiM)
import Halogen (ComponentHTML)
import Network.RemoteData (RemoteData(..))
import Data.Maybe (Maybe(..))
import Inter.Ui.Mod.Link.Component (link_)
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import CSS (block)
import Inter.Ui.Page.Home.QuoteBlock.Style.Style (quoteBlock_, leftCol_, rightCol_, articleTitle_, quoteText_, quoteImage_, imageBand_, quoteIcon_, quoteTitle_, quoteImageBlur, quoteImageContain)
import Data.Newtype (unwrap)
import Util.Html.Clean.Clean (untagAll)
import Data.Array as Array
import Core.Message.Query.Result (Return(..))

renderQuoteBlock :: State -> ComponentHTML Action Slots UiM
renderQuoteBlock s = case s.articleQuote of
  Success (Just { quote, article, slug }) ->
    let
      titleText = case article.title of
        Given t -> untagAll false (unwrap t)
        _ -> ""

      illustrationNode = case article.illustrations of
        Given illustrations -> case Array.head illustrations of
          Just { image: img } ->
            let
              imgSrc = case img of
                Given i -> case i.src of
                  Given srcStr -> srcStr
                  _ -> ""
                _ -> ""
              isPortraitOrSquare = case img of
                Given i -> case i.dimensions of
                  Given d -> case d.width, d.height of
                    Given w, Given h -> w <= h
                    _, _ -> false
                  _ -> false
                _ -> false
            in
              if isPortraitOrSquare then
                quoteImage_ 
                  [ quoteImageBlur [ HP.src imgSrc, HP.alt "" ]
                  , quoteImageContain [ HP.src imgSrc, HP.alt "Article illustration" ]
                  , imageBand_ [ articleTitle_ [ HH.text titleText ] ]
                  ]
              else
                quoteImage_ 
                  [ HH.img [ HP.src imgSrc, HP.alt "Article illustration" ] 
                  , imageBand_ [ articleTitle_ [ HH.text titleText ] ]
                  ]
          Nothing ->
            quoteImage_ 
               [ HH.img [ HP.src "/asset/image/quote.png", HP.alt "Quote illustration" ] 
              , imageBand_ [ articleTitle_ [ HH.text titleText ] ]
              ]
        _ ->
          quoteImage_ 
            [ HH.img [ HP.src "/asset/image/quote.png", HP.alt "Quote illustration" ] 
            , imageBand_ [ articleTitle_ [ HH.text titleText ] ]
            ]
    in
      link_ @"linkQuote"
        { route: Just $ Article slug { consumeMagicLoginToken: Nothing, menu: { magazineIssueOpen: Nothing, search: { openWith: Nothing, withAuthorFilter: Nothing } } }
        , classes: Nothing
        , display: block
        , children:
            [ quoteBlock_
                [ leftCol_
                    [ quoteIcon_ []
                    , quoteText_ [ HH.text ("« " <> quote <> " »") ]
                    ]
                , rightCol_
                    [ illustrationNode
                    ]
                , quoteTitle_ [ HH.text "Citation" ]
                ]
            ]
        }
        HandleQuoteLinkOutput
        unit
  _ -> HH.text ""
