module Inter.Ui.Mod.Input.Type.Style where

import Color (Color)
import Data.Maybe (Maybe(..))

type Style =
  { backgroundColor :: Maybe Color
  , placeholderColor :: Maybe Color
  , textColor :: Maybe Color
  , widthRem :: Maybe Number
  , border ::
      { color :: Maybe Color
      , width ::
          { top :: Maybe Number
          , right :: Maybe Number
          , bottom :: Maybe Number
          , left :: Maybe Number
          }
      }
  }

defaultStyle :: Style
defaultStyle =
  { backgroundColor: Nothing
  , placeholderColor: Nothing
  , textColor: Nothing
  , widthRem: Nothing
  , border:
      { color: Nothing
      , width:
          { top: Nothing
          , right: Nothing
          , bottom: Nothing
          , left: Nothing
          }
      }
  }
