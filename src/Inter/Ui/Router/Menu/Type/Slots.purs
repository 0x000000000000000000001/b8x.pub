module Inter.Ui.Router.Menu.Type.Slots where

import Inter.Ui.Mod.Input.Type.Query as InputQuery
import Inter.Ui.Mod.Input.Type.Output as InputOutput
import Inter.Ui.Mod.Link.Type as Link
import Inter.Ui.Capability.Navigate.Navigate (Route)
import Data.Maybe (Maybe)
import Data.Tuple (Tuple)
import Halogen (Slot)
import Prelude (Unit)

type Slots =
  (items :: Slot Link.Query Link.Output (Tuple String (Maybe Route))
  , searchResults :: Slot Link.Query Link.Output String
  , searchInput :: Slot InputQuery.Query InputOutput.Output Unit
  , newsletterArticles :: Slot Link.Query Link.Output String
  , magazineArticles :: Slot Link.Query Link.Output String
  )
