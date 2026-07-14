module Inter.Ui.Mod.Tooltip.Type where

import Inter.Ui.UiM (UiM)
import Data.Maybe (Maybe(..))
import Halogen (ComponentHTML)
import Halogen.HTML (text)
import Util.Style.Anchor (AnchorPosition)
import Util.Style.Size (Size)

type Offset =
  { vertical :: Number
  , horizontal :: Number
  }

type Style =
  { offset :: Maybe Offset
  , anchorPosition :: Maybe AnchorPosition
  , width :: Maybe Size
  }

type Input action slots =
  { disabled :: Boolean
  , inner :: ComponentHTML action slots UiM
  , outer :: ComponentHTML action slots UiM
  , style :: Style
  }

defaultInput :: ∀ action slots. Input action slots
defaultInput =
  { disabled: false
  , inner: text ""
  , outer: text ""
  , style:
      { offset: Nothing
      , anchorPosition: Nothing
      , width: Nothing
      }
  }
