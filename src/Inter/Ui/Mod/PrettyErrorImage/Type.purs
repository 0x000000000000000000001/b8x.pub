module Inter.Ui.Mod.PrettyErrorImage.Type
  ( Action(..)
  , Border
  , Input
  , Output
  , PrettyErrorImageM
  , Query
  , Slots
  , Sources
  , State
  , Style(..)
  , Try(..)
  , Url
  , defaultInput
  , defaultStyle
  ) where

import Proem

import Color (Color)
import Data.Maybe (Maybe(..))
import Halogen (HalogenM)
import Inter.Ui.Type.State (WithId)
import Inter.Ui.Type.Output (NoOutput)
import Inter.Ui.Type.Query (NoQuery)
import Inter.Ui.Type.Slot (NoSlots)
import Inter.Ui.UiM (UiM)
import Util.Style.Image (ObjectFit, fill)
import Util.Style.Size (Size)

type Url = String

type Sources =
  { first :: Url
  , fallback :: Maybe Url
  }

type Border =
  { radius :: Maybe Size
  , width :: Maybe Number
  , color :: Maybe Color
  }

type Style =
  { fit :: Maybe ObjectFit
  , width :: Maybe Size
  , height :: Maybe Size
  , border :: Border
  , questionMark ::
      { width :: Maybe Size
      }
  , when ::
      { errored ::
          { backgroundColor :: Maybe Color
          , questionMark ::
              { color :: Maybe Color
              }
          }
      }
  , with ::
      { hover ::
          { border :: Border
          }
      }
  }

type Input =
  { loading :: Boolean
  , sources :: Sources
  , style :: Style
  }

defaultStyle :: Style
defaultStyle =
  { fit: Just fill
  , width: Nothing
  , height: Nothing
  , border:
      { radius: Nothing
      , width: Nothing
      , color: Nothing
      }
  , questionMark:
      { width: Nothing
      }
  , when:
      { errored:
          { backgroundColor: Nothing
          , questionMark:
              { color: Nothing
              }
          }
      }
  , with:
      { hover:
          { border:
              { radius: Nothing
              , width: Nothing
              , color: Nothing
              }
          }
      }
  }

defaultInput :: Input
defaultInput =
  { loading: false
  , sources:
      { first: ""
      , fallback: Nothing
      }
  , style: defaultStyle
  }

type Output = NoOutput

type Slots :: Row Type
type Slots = NoSlots

data Try = FirstTry Url | FallbackTry Url | StopTrying

derive instance Eq Try

type State = WithId
  ( input :: Input
  , try :: Try
  )

data Action
  = HandleError
  | Receive Input

type Query :: ∀ k. k -> Type
type Query = NoQuery

type PrettyErrorImageM a = HalogenM State Action Slots Output UiM a
