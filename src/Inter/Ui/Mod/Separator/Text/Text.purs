module Inter.Ui.Mod.Separator.Text.Text
  (text
  ) where

import Proem

import Data.String (toLower)
import Halogen (ComponentHTML)
import Halogen.HTML as HH
import Halogen.HTML.Core (ElemName(..))
import Halogen.HTML.Elements (element)
import Inter.Ui.Mod.Separator.Text.Style as Style
import Inter.Ui.Mod.Separator.Type (TextElementTag)
import Inter.Ui.UiM (UiM)
import Util.Style.Classname (class_)

text :: ∀ action slots. TextElementTag -> String -> ComponentHTML action slots UiM
text tag str =
  element
    (name tag)
    [ class_ Style.staticClass ]
    [ HH.text str ]

name :: TextElementTag -> ElemName
name = ElemName ◁ toLower ◁ show
