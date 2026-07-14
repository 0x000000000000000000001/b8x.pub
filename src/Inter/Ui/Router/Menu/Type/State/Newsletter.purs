module Inter.Ui.Router.Menu.Type.State.Newsletter where

import Proem

import Core.Mod.Time.Month (Month)
import Core.Mod.Time.Year (Year)
import Data.Lens (Lens')
import Data.Lens.Record (prop)
import Inter.Ui.Type.Remote (Remote)
import Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Result as GetNewsletterCalendar
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Result as ListNewsletterArticles

data Page
  = Years
  | Months { year :: Year }
  | Articles { year :: Year, month :: Month, fromShortcut :: Boolean }

derive instance Eq Page

type State =
  { page :: Page
  , calendar :: Remote GetNewsletterCalendar.Result
  , articles :: Remote ListNewsletterArticles.Result
  }

page' = π :: Π "page"

_page :: ∀ a r. Lens' { page :: a | r } a
_page = prop page'

calendar' = π :: Π "calendar"

_calendar :: ∀ a r. Lens' { calendar :: a | r } a
_calendar = prop calendar'

articles' = π :: Π "articles"

_articles :: ∀ a r. Lens' { articles :: a | r } a
_articles = prop articles'
