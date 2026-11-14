module Inter.Ui.Page.About.Render where

import Proem hiding (div)

import Halogen (ComponentHTML)
import Halogen.HTML (div, h1, p, text, br)
import Halogen.HTML.Core (ClassName(..))
import Halogen.HTML.Properties (classes)
import Inter.Ui.Page.About.Style.Index (sheet)
import Inter.Ui.Page.About.Style.Style (about_)
import Inter.Ui.Page.About.Type (Action, Slots, State)
import Inter.Ui.UiM (UiM)

render :: State -> ComponentHTML Action Slots UiM
render _ =
  about_
    [ sheet
    , div [ classes [ ClassName "about-container" ] ]
        [ h1 [ classes [ ClassName "about-title" ] ] [ text "Qui nous sommes" ]
        , p [ classes [ ClassName "about-text" ] ]
            [ text "Des anciens du magazine Books, mort de sa belle mort durant l'hiver 2023. Bénévoles passionnés, nous restons convaincus de la valeur de ce concept : rendre compte d'une sélection de livres récemment parus ailleurs qu'en France pour mieux éclairer l'actualité."
            , br []
            , br []
            , text "Nous nous sommes associés à ActuaLitté, premier site francophone consacré au monde de l'édition."
            ]
        ]
    ]
