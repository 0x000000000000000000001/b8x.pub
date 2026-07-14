module Inter.Ui.Mod.Newsletter.Render
  ( render
  ) where

import Proem hiding (div)

import Data.Maybe (Maybe(..))
import Halogen (ComponentHTML)
import Halogen.HTML (br, button, form, h3, img, p, strong_, text)
import Halogen.HTML as HH
import Halogen.HTML.Core (ClassName(..))
import Halogen.HTML.Events (onSubmit)
import Halogen.HTML.Properties (src, disabled, type_, ButtonType(..), class_)
import Inter.Ui.Mod.Input.Component as InputComponent
import Inter.Ui.Mod.Input.Type.Input as InputType
import Inter.Ui.Mod.Input.Type.Value (ControlledValue(..))
import Inter.Ui.Mod.Newsletter.Style.Style (booksletter_)
import Inter.Ui.Mod.Newsletter.Type (Action(..), Slots, State, Status(..))
import Inter.Ui.UiM (UiM)

render :: State -> ComponentHTML Action Slots UiM
render state =
  booksletter_
    [ img [ src "/asset/image/newsletter.svg" ]
    , HH.div_
        [ h3 [] [ text "Ne manquez rien !" ]
        , p [] [ strong_ [ text "L'esprit critique se cultive." ], br [], text "Inscrivez-vous à la Booksletter et lisez,", br [], text "chaque vendredi, une newsletter de ", strong_ [ text "qualité" ], text "." ]
        , form [ onSubmit \event -> Submit event ]
            [ InputComponent.input_ @"emailInput" (InputType.defaultInput { debounceMs = 0.0 }) { label = Just "Votre adresse email", placeholder = Just "E.g. jean@dupont.com", value = Controlled state.email } HandleInput unit
            , button
                ( [ type_ ButtonSubmit
                  , disabled (state.status /= Idle)
                  ] <> case state.status of
                    Submitting -> [ class_ (ClassName "blue") ]
                    Success -> [ class_ (ClassName "green") ]
                    _ -> []
                )
                [ text $ buttonText state.status ]
            ]
        ]
    ]

buttonText :: Status -> String
buttonText = case _ of
  Idle -> "S'inscrire"
  Submitting -> "En cours..."
  InvalidEmail -> "Email invalide"
  Failure -> "Echec"
  Success -> "Validé !"
