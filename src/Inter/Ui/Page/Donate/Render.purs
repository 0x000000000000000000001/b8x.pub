module Inter.Ui.Page.Donate.Render where

import Proem hiding (div, top)

import Halogen (ComponentHTML)
import Halogen.HTML (a, button, div, h1, h3, p, strong, text)
import Halogen.HTML.Events (onClick)
import Halogen.HTML.Properties (classes, href, target)
import Inter.Ui.Page.Donate.Type (Action(..), Slots, State)
import Inter.Ui.UiM (UiM)
import Halogen.HTML.Core (ClassName(..))

import Data.Maybe (Maybe(..))
import Inter.Ui.Page.Donate.Style.Index (sheet)
import Inter.Ui.Page.Donate.Style.Style (donate_)

render :: State -> ComponentHTML Action Slots UiM
render state =
  donate_
    [ sheet
    , div [ classes [ ClassName "donate-container" ] ]
        [ h1 [ classes [ ClassName "donate-title" ] ] [ text "Soutenez-nous !" ]
        , p [ classes [ ClassName "donate-subtitle" ] ]
            [ text "Vous aimez Books, mais les pubs ne sont pas votre tasse de thé ? Soutenez Books par un don défiscalisé et laissez-vous emporter par nos récits, sans la moindre distraction. Pas d'actionnaires, juste des plumes financées par "
            , strong [] [ text "les lecteurs" ]
            , text ". Pour vous remercier de votre soutien, on vous offre une évasion totale : "
            , strong [] [ text "zéro publicité" ]
            , text "."
            ]
        , div [ classes [ ClassName "donate-steps" ] ]
            ( [ renderStep "1" "Choisissez votre soutien"
                  "Faites un don du montant de votre choix sur HelloAsso. Pensez simplement à utiliser votre e-mail habituel !"
                  (Just "https://www.helloasso.com/associations/les-amis-de-books/collectes/relancons-la-booksletter-3")
                  Nothing
              ]
                <>
                  ( if state.isLoggedIn then []
                    else
                      [ renderStep "2" "Connectez-vous ici"
                          "Connectez-vous avec ce même e-mail en un clic, via notre lien magique sécurisé (aucun mot de passe à retenir)."
                          Nothing
                          (Just OpenLoginModal)
                      ]
                  )
                <>
                  [ renderStep (if state.isLoggedIn then "2" else "3") "Bonne lecture !"
                      "Votre navigation et votre interface sont désormais débarrassées de toute bannière publicitaire !"
                      Nothing
                      Nothing
                  ]
            )
        ]
    ]

renderStep :: String -> String -> String -> Maybe String -> Maybe Action -> ComponentHTML Action Slots UiM
renderStep num title desc mLink mAction =
  div [ classes [ ClassName "donate-step" ] ]
    [ div [ classes [ ClassName "step-number" ] ] [ text num ]
    , div [ classes [ ClassName "step-content" ] ]
        [ h3 [ classes [ ClassName "step-title" ] ] [ text title ]
        , p [ classes [ ClassName "step-desc" ] ] [ text desc ]
        , case mLink of
            Just link -> a [ classes [ ClassName "step-action" ], href link, target "_blank" ] [ text "Soutenir sur HelloAsso" ]
            Nothing -> case mAction of
              Just action -> button [ classes [ ClassName "step-action" ], onClick \_ -> action ] [ text "Me connecter" ]
              Nothing -> text ""
        ]
    ]
