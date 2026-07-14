module Inter.Ui.Page.Home.Render
  (render
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

render :: State -> ComponentHTML Action Slots UiM
render s = case s.frontPage of
  Failure err -> home_ [ error_ err ]
  _ -> 
    home_
      [ frontPage s.id s.frontPage
      , renderQuoteBlock s
      , HH.slot (π @"newsletter") unit NewsletterComponent.component unit HandleNewsletterOutput
      , renderNewsletterArticles s
      , renderNews s
      , renderMostRead s
      ]
