module Inter.Ui.Page.Legal.Render where

import Proem hiding (div)

import Halogen (ComponentHTML)
import Halogen.HTML (div, h1, p, text)
import Halogen.HTML.Core (ClassName(..))
import Halogen.HTML.Properties (classes)
import Inter.Ui.Page.Legal.Style.Index (sheet)
import Inter.Ui.Page.Legal.Style.Style (legal_)
import Inter.Ui.Page.Legal.Type (Action, Slots, State)
import Inter.Ui.UiM (UiM)

render :: State -> ComponentHTML Action Slots UiM
render _ =
  legal_
    [ sheet
    , div [ classes [ ClassName "legal-container" ] ]
        [ h1 [ classes [ ClassName "legal-title" ] ] [ text "Mentions légales" ]
        , p [ classes [ ClassName "legal-text" ] ]
            [ text "La Booksletter est une production de Les Amis de Books, association loi de 1901 créée le 5 février 2016. Siège : c/o Olivier Postel-Vinay, 43 rue du Temple, 75004 Paris"
            ]
        ]
    ]
