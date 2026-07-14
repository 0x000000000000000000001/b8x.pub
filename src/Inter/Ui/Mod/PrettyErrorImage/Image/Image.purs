module Inter.Ui.Mod.PrettyErrorImage.Image.Image
  (image
  ) where

import Proem

import Data.Maybe (Maybe(..))
import Halogen (ComponentHTML)
import Halogen.HTML.Events (onError)
import Halogen.HTML.Properties (src)
import Inter.Ui.Mod.PrettyErrorImage.Image.Style as Style
import Inter.Ui.Mod.PrettyErrorImage.Type (Action(..), Slots, State, Try(..))
import Inter.Ui.UiM (UiM)

image :: State -> ComponentHTML Action Slots UiM
image { id, try } =
  let
    src_ = case try of
      FirstTry url -> Just url
      FallbackTry url -> Just url
      _ -> Nothing
  in
    Style.image id
      $ (src_ ?? (\s_ -> [ src s_ ]) ⇔ [])
      <> [ onError \_ -> HandleError ]
