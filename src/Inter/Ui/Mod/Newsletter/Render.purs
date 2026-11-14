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
import Inter.Ui.Mod.Newsletter.Style.Style (booksletter_, staticClass)
import Inter.Ui.Mod.Newsletter.Type (Action(..), Slots, State, Status(..))
import Inter.Ui.UiM (UiM)
import Util.Style.ContainerQuery (containerQueryStyle)

render :: State -> ComponentHTML Action Slots UiM
render state =
  booksletter_
    [ containerQueryStyle "" "max-width: 850px"
        ( "." <> staticClass <> " { margin-top: 1rem !important; padding: 2rem 1rem !important; }"
       <> " .newsletter-img { display: none !important; }"
       <> " .newsletter-content { margin-left: 0 !important; flex-basis: auto !important; padding: 0 !important; }"
       <> " .newsletter-content h3 { font-size: 2.2rem !important; line-height: 120% !important; margin-bottom: 1rem !important; }"
       <> " .newsletter-content p { font-size: 1.2rem !important; margin-bottom: 2rem !important; }"
       <> " .newsletter-content .mobile-hide { display: none !important; }"
       <> " .newsletter-content form { flex-direction: column !important; width: 100% !important; gap: 0 !important; margin-top: 0 !important; }"
       <> " .newsletter-content form div { width: 100% !important; flex-grow: unset !important; }"
       <> " .newsletter-content form input { width: 100% !important; border-radius: 6px 6px 0 0 !important; border-bottom: none !important; }"
       <> " .newsletter-content form button { width: 100% !important; border-radius: 0 0 6px 6px !important; padding: 1rem !important; }"
        )
    , img [ src "/asset/image/newsletter.svg", class_ (ClassName "newsletter-img") ]
    , HH.div [ class_ (ClassName "newsletter-content") ]
        [ h3 [] [ text "Ne manquez rien !" ]
        , p [] [ strong_ [ text "L'esprit critique se cultive." ], br [], text "Inscrivez-vous à la Booksletter et lisez,", br [ class_ (ClassName "mobile-hide") ], text " chaque vendredi, une newsletter de ", strong_ [ text "qualité" ], text "." ]
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
