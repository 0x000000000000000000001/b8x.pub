module Inter.Ui.Page.Home.Render
  ( render
  ) where

import Proem hiding (div)

import Halogen (ComponentHTML)
import Inter.Ui.Page.Home.FrontPage.FrontPage (frontPage)
import Inter.Ui.Page.Home.Style.Style (home_)
import Inter.Ui.Page.Home.Type (Action(..), Slots, State)
import Inter.Ui.Page.Home.News.Render (renderNews)
import Inter.Ui.Page.Home.MostRead.Render (renderMostRead)
import Inter.Ui.Page.Home.NewsletterArticles.Render (renderNewsletterArticles)
import Inter.Ui.Mod.Newsletter.Component as NewsletterComponent
import Halogen.HTML as HH
import Inter.Ui.UiM (UiM)
import Inter.Ui.Page.Article.Error.Error (error_)
import Network.RemoteData (RemoteData(..))
import Inter.Ui.Page.Home.QuoteBlock.Render (renderQuoteBlock)
import Inter.Ui.Mod.AdPlaceholder.AdPlaceholder as AdPlaceholder
import Inter.Ui.Mod.StopPub.Type (defaultStopPubPlacement)
import Util.Style.Size as Size
import Halogen.HTML.Properties as HP
import Data.Maybe (Maybe(..))
import Inter.Ui.Type.Device (Device(..))

render :: State -> ComponentHTML Action Slots UiM
render s = case s.frontPage of
  Failure err -> home_ [ error_ err ]
  _ ->
    home_
      [ if s.context < Desktop then HH.text "" else HH.slot (π @"adPlaceholder") "megaban_1" AdPlaceholder.component { width: Size.Px 728.0, height: Size.Px 90.0, name: "megaban_1", stopPubPlacement: defaultStopPubPlacement, wrapperClass: Nothing, wrapperStyle: Just "width: 100%; max-width: 90rem; margin-top: -1rem; margin-bottom: 2rem; display: flex; justify-content: center;" } HandleAdLinkOutput
      , frontPage s.id s.context s.frontPage
      , HH.div
          [ HP.class_ (HH.ClassName "home-main-col-wrapper") ]
          [ HH.div
              [ HP.class_ (HH.ClassName "home-main-col")
              , HP.style "display: flex; flex-direction: column; flex: 1;"
              ]
              [ renderQuoteBlock s
              , HH.slot (π @"newsletter") unit NewsletterComponent.component unit HandleNewsletterOutput
              ]
          , if s.context < Desktop then HH.text ""
            else HH.slot (π @"adPlaceholder") "grand_angle_1" AdPlaceholder.component { width: Size.Px 300.0, height: Size.Px 600.0, name: "grand_angle_1", stopPubPlacement: defaultStopPubPlacement, wrapperClass: Nothing, wrapperStyle: Just "display: flex; justify-content: center; align-items: flex-start; position: sticky; top: 3rem;" } HandleAdLinkOutput
          ]
      , HH.style []
          [ HH.text
              """
            .home-main-col-wrapper {
                display: flex;
                flex-direction: column;
                width: 100%;
                max-width: 90rem;
                align-items: stretch;
                margin-top: 6rem;
                margin-bottom: 0rem;
            }
            .incontent-ad-wrapper { 
                display: flex;
                justify-content: center;
                align-items: center;
                width: 100%;
                max-width: 90rem; 
                margin-left: auto; 
                margin-right: auto;
                margin-top: 4rem;
                margin-bottom: 2rem;
            }
            .home-main-col {
                gap: 1.5rem;
            }
            @media (min-width: 768px) {
                .home-main-col-wrapper {
                    flex-direction: row;
                    justify-content: space-between;
                    align-items: flex-start;
                    gap: 2rem;
                    margin-top: 4rem;
                    margin-bottom: -3rem;
                }
                .incontent-ad-wrapper { 
                    margin-top: 3rem; 
                    margin-bottom: -3rem; 
                }
                .home-main-col {
                    gap: 4rem;
                }
            }
          """
          ]
      , renderNewsletterArticles s
      , if s.context < Desktop then HH.text "" else HH.slot (π @"adPlaceholder") "incontent_1" AdPlaceholder.component { width: Size.Pct 100.0, height: Size.Px 90.0, name: "incontent_1", stopPubPlacement: defaultStopPubPlacement, wrapperClass: Just "incontent-ad-wrapper", wrapperStyle: Nothing } HandleAdLinkOutput
      , renderNews s
      , if s.context < Desktop then HH.text "" else HH.slot (π @"adPlaceholder") "incontent_2" AdPlaceholder.component { width: Size.Pct 100.0, height: Size.Px 90.0, name: "incontent_2", stopPubPlacement: defaultStopPubPlacement, wrapperClass: Just "incontent-ad-wrapper", wrapperStyle: Nothing } HandleAdLinkOutput
      , renderMostRead s
      , if s.context < Desktop then HH.text "" else HH.slot (π @"adPlaceholder") "megaban_2" AdPlaceholder.component { width: Size.Px 728.0, height: Size.Px 90.0, name: "megaban_2", stopPubPlacement: defaultStopPubPlacement, wrapperClass: Nothing, wrapperStyle: Just "width: 100%; max-width: 90rem; margin-top: 2rem; margin-bottom: -2rem; display: flex; justify-content: center;" } HandleAdLinkOutput
      ]
