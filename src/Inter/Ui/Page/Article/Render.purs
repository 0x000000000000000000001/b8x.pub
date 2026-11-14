module Inter.Ui.Page.Article.Render
  (render
  ) where

import Proem

import Data.Maybe (Maybe(..))
import Halogen (ComponentHTML)
import Halogen.HTML (div_, text)
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Halogen as H
import Inter.Ui.Mod.AdPlaceholder.AdPlaceholder as AdPlaceholder
import Inter.Ui.Mod.StopPub.Type (defaultStopPubPlacement)
import Util.Style.Size as Size
import Inter.Ui.Page.Article.Content.Content (content)
import Inter.Ui.Page.Article.Hero.Hero (hero, heroLoading)
import Inter.Ui.Page.Article.Style.Style as Style
import Inter.Ui.Page.Article.Type (Action(..), Slots, State)
import Inter.Ui.Page.Article.Related.Related (related)
import Inter.Ui.Page.Article.NotFound.NotFound (notFound)
import Inter.Ui.Page.Article.Error.Error (error_)
import Inter.Ui.Page.Article.Books.Books (books)
import Inter.Ui.UiM (UiM)
import Core.Message.Query.Result (Fold(..), Return(..))
import Data.Array as Array
import Network.RemoteData (RemoteData(..))

render :: State -> ComponentHTML Action Slots UiM
render state = case state.article of
  Success (Just articleData) ->
    let
      hasBooks = case articleData.books of
        Given (Unfolded bookList) -> Array.length bookList > 0
        _ -> false
    in
    Style.articleContainer state.id [ HP.attr (H.AttrName "data-loaded") "" ]
      [ HH.slot (π @"adPlaceholder") "megaban_1" AdPlaceholder.component { width: Size.Px 728.0, height: Size.Px 90.0, name: "megaban_1", stopPubPlacement: defaultStopPubPlacement, wrapperClass: Nothing, wrapperStyle: Just "width: 100%; max-width: 90rem; margin-top: 1.1rem; margin-bottom: 2rem; margin-left: auto; margin-right: auto; display: flex; justify-content: center;" } HandleAdLinkOutput
      , hero state articleData
      , content state articleData
      , if hasBooks then HH.slot (π @"adPlaceholder") "megaban_2" AdPlaceholder.component { width: Size.Px 728.0, height: Size.Px 90.0, name: "megaban_2", stopPubPlacement: defaultStopPubPlacement, wrapperClass: Just "megaban-2-wrapper", wrapperStyle: Nothing } HandleAdLinkOutput else HH.text ""
      , books state articleData
      , related state
      , HH.style []
          [ HH.text
              """
            .incontent-ad-wrapper { 
                display: flex;
                justify-content: center;
                min-height: 600px; 
                width: 100%;
                max-width: 90rem; 
                margin-top: 2rem; 
                margin-bottom: 2rem; 
                margin-left: auto; 
                margin-right: auto; 
            }
            .incontent-ad-wrapper.loaded {
                min-height: 0px;
            }
            .megaban-2-wrapper {
                width: 100%; 
                max-width: 90rem; 
                margin-top: 0rem; 
                margin-bottom: -3rem; 
                margin-left: auto; 
                margin-right: auto; 
                display: flex; 
                justify-content: center;
            }
            @media (min-width: 768px) {
              .incontent-ad-wrapper { min-height: 90px; }
              .megaban-2-wrapper { margin-top: 6rem; }
            }
          """
          ]
      ]
  Success Nothing -> notFound
  Failure err -> error_ err
  Loading ->
    Style.articleContainer_ state.id
      [ HH.slot (π @"adPlaceholder") "megaban_1" AdPlaceholder.component { width: Size.Px 728.0, height: Size.Px 90.0, name: "megaban_1", stopPubPlacement: defaultStopPubPlacement, wrapperClass: Nothing, wrapperStyle: Just "width: 100%; max-width: 90rem; margin-top: 1.1rem; margin-bottom: 2rem; margin-left: auto; margin-right: auto; display: flex; justify-content: center;" } HandleAdLinkOutput
      , heroLoading state state.cachedInfo 
      ]
  NotAsked -> div_ [ text "" ]
