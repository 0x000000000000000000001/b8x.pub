module Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Core where

import Core.Feat.Review.Message.Query.SearchArticles.Result (Article)
import Halogen.HTML (HTML)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.BooksAndAuthors.BooksAndAuthors (booksAndAuthors)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Content.Content (content)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Title.Title (title)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Style.Style (core_)

core :: ∀ w i. { excerptSearches :: Array String, articleAuthorTokens :: Array String, bookAuthorTokens :: Array String } -> Article -> HTML w i
core normSearches article = 
  core_ 
    [ title normSearches article
    , booksAndAuthors normSearches article
    , content normSearches article
    ]
