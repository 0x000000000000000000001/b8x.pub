module Inter.Ui.Mod.Login.Render (render) where

import Proem hiding (div)

import Halogen.HTML (ClassName(..), ComponentHTML, div, form, span, strong_, text)
import Halogen.HTML.Properties (classes, type_, ButtonType(..))
import Halogen.HTML.Events (onSubmit)
import Inter.Ui.Mod.Input.Component as Input
import Inter.Ui.Mod.Login.Type (Action(..), Slots, State)
import Inter.Ui.Mod.Input.Type.Value (ControlledValue(..), When(..))
import Inter.Ui.UiM (UiM)
import Inter.Ui.Mod.Input.Type.Input (defaultInput)
import Inter.Ui.Mod.Input.Type.Theme (Theme(..))
import Color as CSS
import Data.Maybe (Maybe(..))

import Inter.Ui.Mod.LoadingDots.LoadingDots as LoadingDots
import Inter.Ui.Mod.LoadingDots.Type as LoadingDotsT
import Inter.Ui.Mod.Button.Button as Button
import Halogen.HTML.Properties as HP
import Halogen.HTML.Core as H

render :: State -> ComponentHTML Action Slots UiM
render state =
  div [ classes [ ClassName "login" ] ]
    if state.submitted then
      [ div [ HP.attr (H.AttrName "style") "color: white; text-align: center;" ]
          [ span [] [ text "Veuillez consulter votre boite de messagerie à l'adresse que vous venez d'indiquer. Vous y trouverez un " ]
          , strong_ [ text "lien de connexion" ]
          , span [] [ text " automatique sur lequel cliquer." ]
          ]
      ]
    else
      [ form [ classes [ ClassName "login-form" ], onSubmit \event -> Submit event ]
          [ div [ HP.attr (H.AttrName "style") "margin-top: 2rem;" ]
              [ Input.input
                  ( defaultInput
                      { value = Uncontrolled Rightaway state.email
                      , placeholder = Just "E.g. jean.dupont@email.com"
                      , label = Just "Email"
                      , style = defaultInput.style 
                          { widthRem = Just 30.0 
                          , textColor = Just CSS.white
                          , placeholderColor = Just (CSS.rgba 255 255 255 0.6)
                          }
                      , debounceMs = 0.0
                      , theme = LightOutlined
                      , helper = Just "Utilisez le même email que pour vos dons."
                      }
                  )
                  HandleEmailInput
              ]
          , div [ HP.attr (H.AttrName "style") "margin-top: 2rem; margin-bottom: 2rem; display: flex; justify-content: center;" ]
              [ if state.loading then LoadingDots.loadingDots { opacity: 0.7, color: LoadingDotsT.White, sizeRem: 0.5 }
                else Button.button
                  { bgClass: if state.invalidEmail then "" else "red"
                  , fgClass: "white"
                  }
                  [ type_ ButtonSubmit
                  , HP.disabled state.invalidEmail
                  ]
                  [ text if state.invalidEmail then "Email invalide" else "Me connecter" ]
              ]
          ]
      ]
