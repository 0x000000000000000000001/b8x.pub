module Inter.Ui.Page.Donate.Render where

import Proem hiding (div, top)

import Data.Maybe (Maybe(..))
import Halogen (ComponentHTML)
import Halogen.HTML (a, br_, button, div, h1, h2, h3, p, strong, text)
import Halogen.HTML.Core (ClassName(..))
import Halogen.HTML.Events (onClick)
import Halogen.HTML.Properties (classes, href, target)
import Inter.Ui.Page.Donate.Style.Index (sheet)
import Inter.Ui.Page.Donate.Style.Style (donate_)
import Inter.Ui.Page.Donate.Type (Action(..), Slots, State)
import Inter.Ui.UiM (UiM)

render :: State -> ComponentHTML Action Slots UiM
render state =
  donate_
    [ sheet
    , div [ classes [ ClassName "donate-container" ] ]
        [ h2 [ classes [ ClassName "donate-subtitle" ] ] [ text "Marre des pubs ?" ]
        , h1 [ classes [ ClassName "donate-title" ] ] [ text "Soutenez-nous !" ]
        , p [ classes [ ClassName "donate-text" ] ]
            [ text "Vous aimez Books, mais les pubs ne sont pas votre tasse de thé ? "
            , strong [] [ text "Soutenez Books" ]
            , text " par un don régulier (à partir de 4 € / mois) et laissez-vous emporter par nos récits, sans la moindre distraction. Pour vous remercier de cet engagement mensuel, nous vous offrons une évasion totale : "
            , strong [] [ text "zéro publicité" ]
            , text "."
            , br_
            , br_
            , text "Vous préférez faire un don ponctuel ? Même si cela ne permet pas de désactiver la publicité, c'est évidemment possible et nous l'accueillerons aussi avec une immense gratitude."
            , br_
            , br_
            , text "Nous n'avons pas d'actionnaires, juste des plumes passionnées et financées par "
            , strong [] [ text "nos lecteurs" ]
            , text "."
            ]
        , div [ classes [ ClassName "donate-steps" ] ]
            ( [ renderStep "1" "Choisissez votre soutien"
                  ( if state.isLoggedIn then
                      [ text "Sur HelloAsso, choisissez le don mensuel (dès 4 €) pour profiter du site sans pub, ou faites un don ponctuel. Pensez simplement à "
                      , strong [] [ text "utiliser votre e-mail habituel" ]
                      , text " (celui qui vous a permis de vous connecter ici) !"
                      ]
                    else
                      [ text "Sur HelloAsso, choisissez le don mensuel (dès 4 €) pour profiter du site sans pub, ou faites un don ponctuel. Pensez simplement à "
                      , strong [] [ text "utiliser votre e-mail habituel" ]
                      , text " ! Il vous servira pour vous connecter sur notre site."
                      ]
                  )
                  (Just "https://www.helloasso.com/associations/les-amis-de-books/formulaires/2")
                  Nothing
              ]
                <>
                  ( if state.isLoggedIn then []
                    else
                      [ renderStep "2" "Connectez-vous ici"
                          [ text "Connectez-vous avec ce même e-mail en un clic, via notre lien magique sécurisé (aucun mot de passe à retenir)." ]
                          Nothing
                          (Just OpenLoginModal)
                      ]
                  )
                <>
                  [ renderStep (if state.isLoggedIn then "2" else "3") "Bonne lecture !"
                      [ text "Votre navigation et votre interface sont désormais débarrassées de toute bannière publicitaire !" ]
                      Nothing
                      Nothing
                  ]
            )
        ]
    ]

renderStep :: String -> String -> Array (ComponentHTML Action Slots UiM) -> Maybe String -> Maybe Action -> ComponentHTML Action Slots UiM
renderStep num title desc mLink mAction =
  div [ classes [ ClassName "donate-step" ] ]
    [ div [ classes [ ClassName "step-number" ] ] [ text num ]
    , div [ classes [ ClassName "step-content" ] ]
        [ h3 [ classes [ ClassName "step-title" ] ] [ text title ]
        , p [ classes [ ClassName "step-desc" ] ] desc
        , case mLink of
            Just link -> a [ classes [ ClassName "step-action" ], href link, target "_blank" ] [ text "Soutenir sur HelloAsso" ]
            Nothing -> case mAction of
              Just action -> button [ classes [ ClassName "step-action" ], onClick \_ -> action ] [ text "Me connecter" ]
              Nothing -> text ""
        ]
    ]
