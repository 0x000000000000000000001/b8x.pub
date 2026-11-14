module Inter.Ui.Mod.StopPub.Type where

import Prelude (negate)
import Util.Style.Size (Size(..))
import Inter.Ui.Mod.Link.Type as Link
import Inter.Ui.Type.Query (NoQuery)
import Data.Maybe (Maybe)

data Corner = TopLeft | TopRight | BottomLeft | BottomRight
type Placement = { corner :: Corner, desktopTranslate :: { x :: Size, y :: Size }, mobileTranslate :: { x :: Size, y :: Size } }

defaultStopPubPlacement :: Placement
defaultStopPubPlacement = { corner: TopRight, desktopTranslate: { x: Pct 110.0, y: Pct (-40.0) }, mobileTranslate: { x: Pct 30.0, y: Pct (-70.0) } }

type Input =
  { target :: Maybe String
  , placement :: Placement
  , name :: String
  }

type Output = Link.Output

type Query :: ∀ k. k -> Type
type Query = NoQuery
