module Core.Feat.Reference.Message.Query.SearchBooks.Query where
import Data.Maybe (Maybe(..))

import Proem
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Config.PublicConfig (askPublicConfig)
import Core.Feat.Reference.Message.Query.SearchBooks.Payload (Fields, Payload)
import Core.Feat.Reference.Message.Query.SearchBooks.Result (Result)
import Core.Feat.Reference.Message.Query.SearchBooks.State (State)
import Core.Feat.Reference.Message.Query.SearchBooks.Projection.Projection (Book, findBooks)
import Core.Mod.Projection.Finder.Finder (defaultFindOpt, getReadModelHash)
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit(..))
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Core.Mod.Projection.Finder.Sort (noSort)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype, unwrap)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)
import Core.Message.Query.Handle (build)
import Core.Mod.Book.Cover.Message.Query.Build (buildCover)

newtype SearchBooks = SearchBooks Payload

derive instance Newtype SearchBooks _
derive instance Generic SearchBooks _
derive newtype instance Random SearchBooks
derive newtype instance WriteForeign SearchBooks
derive newtype instance ReadForeign SearchBooks

instance Reflect SearchBooks where
  reflectName = reflectConstructorName @SearchBooks

instance IsQuery SearchBooks State Fields Payload Result where
  description = "Search books"

  cacheStrategy _ = do
    hash <- getReadModelHash @Book Nothing
    η $ defaultCached hash

  handle (SearchBooks { filter, limit: BoundedLimit limit_, expectation, after, needs }) = do
    config <- askPublicConfig
    page <- findBooks (defaultFindOpt { filter = filter, limit = Finite limit_, expectation = expectation, after = after, sort = noSort })

    η
      { books: page.items <#> unwrap ▷ \e ->
          { id: build needs.id e.id
          , name: build needs.name e.name
          , year: build needs.year e.year
          , cover: buildCover config.objectStorage.urlBase needs.cover e.cover
          , authors: build needs.authors e.authors
          , editor: build needs.editor e.editor
          }
      , limit: limit_
      , hasNextPage: page.hasNextPage
      }
