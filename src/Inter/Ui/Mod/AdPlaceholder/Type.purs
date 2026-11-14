module Inter.Ui.Mod.AdPlaceholder.Type where

import Util.Style.Size (Size)
import Inter.Ui.Mod.Link.Type as Link
import Inter.Ui.Type.Query (NoQuery)
import Data.Maybe (Maybe)

import Inter.Ui.Mod.StopPub.Type (Placement)

type Input =
  { width :: Size
  , height :: Size
  , name :: String
  , stopPubPlacement :: Placement
  , wrapperClass :: Maybe String
  , wrapperStyle :: Maybe String
  }

type Output = Link.Output

type Query :: ∀ k. k -> Type
type Query = NoQuery
