module Inter.Ui.Router.Menu.Type.State.Magazine where

import Proem

import Core.Mod.Time.Year (Year)

import Data.Maybe (Maybe)
import Data.Lens (Lens')
import Data.Lens.Record (prop)
import Inter.Ui.Type.Remote (Remote)
import Core.Feat.Reference.Message.Query.GetMagazineCalendar.Result as GetMagazineCalendar
import Core.Mod.MagazineIssue.Slug.Slug (Slug)
import Core.Feat.Review.Message.Query.SearchArticles.Result as SearchArticles

data Page
  = Years
  | Covers { year :: Year }
  | Articles { year :: Maybe Year, slug :: Slug }

derive instance Eq Page

type State =
  { page :: Page
  , calendar :: Remote GetMagazineCalendar.Result
  , articles :: Remote SearchArticles.Result
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
