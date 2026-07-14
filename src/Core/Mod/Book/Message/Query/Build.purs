module Core.Mod.Book.Message.Query.Build where

import Proem

import Core.Message.Query.Payload as QueryPayload
import Core.Message.Query.Result as QueryResult
import Core.Mod.Book.Message.Query.Opt (BookOpt_, BookInnerNeeds_)
import Core.Mod.Book.Id.Id (BookId)
import Data.Newtype (unwrap)
import Core.Message.Query.Handle (build)
import Core.Mod.Book.Message.Query.Result.Books (Book_) as Result
import Core.Mod.Book.Cover.Message.Query.Build (buildCover)
import Core.Mod.Article.Projection.Books.Books as Projection

buildBook :: String -> BookOpt_ -> BookInnerNeeds_ -> Projection.Book -> Result.Book_
buildBook urlBase _ innerNeeds b =
  { id: build innerNeeds.id b.id
  , name: build innerNeeds.name b.name
  , year: build innerNeeds.year b.year
  , cover: buildCover urlBase innerNeeds.cover b.cover
  , authors: build innerNeeds.authors (b.authors <#> \au -> { id: au.id, name: au.name })
  , editor: build innerNeeds.editor b.editor
  }

buildBooks
  :: ∀ r
   . QueryPayload.Need (QueryPayload.Fold BookOpt_) (QueryPayload.Fold BookInnerNeeds_)
  -> Projection.Books
  -> (BookOpt_ -> BookInnerNeeds_ -> Projection.Book -> r)
  -> QueryResult.Return (QueryResult.Fold (Array BookId) (Array r))
buildBooks QueryPayload.NotNeeded _ _ = QueryResult.NotGivenBecauseNotNeeded
buildBooks (QueryPayload.Needed bookNeeds innerNeeds) books f = QueryResult.Given $
  let
    rawBooks = (unwrap books).books
  in
    case bookNeeds, innerNeeds of
      QueryPayload.Folded, QueryPayload.Folded -> QueryResult.Folded (rawBooks <#> \b -> b.id)
      QueryPayload.Unfolded bNeeds', QueryPayload.Unfolded bInnerNeeds' -> QueryResult.Unfolded (rawBooks <#> f bNeeds' bInnerNeeds')
      _, _ -> QueryResult.Folded (rawBooks <#> \b -> b.id)
