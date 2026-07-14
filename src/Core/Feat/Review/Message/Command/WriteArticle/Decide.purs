module Core.Feat.Review.Message.Command.WriteArticle.Decide where

import Proem hiding (append)

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Message.Command.Handle.Upload (UPLOAD)
import Core.Message.Command.Handle.Upload as Upload
import Core.Feat.Review.Message.Command.WriteArticle.Payload (Payload)
import Core.Feat.Review.Message.Command.WriteArticle.State (State)
import Core.Mod.Author.Exception.AuthorNotReferenced (AuthorNotReferenced(..))
import Core.Mod.Author.State as Author
import Core.Mod.Book.Exception.BookNotReferenced (BookNotReferenced(..))
import Core.Mod.Book.State as Book
import Core.Mod.Article.Exception.ArticleAlreadyWritten (ArticleAlreadyWritten(..))
import Core.Mod.Article.State as Article
import Core.Mod.Article.Slug.Exception (InvalidSlug(..))
import Core.Mod.Article.Slug.Slug (make_)
import Core.Mod.Html.Html as Html
import Util.Type.String.ToString (toString)
import Data.Either (Either(..))
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Data.Foldable (for_)
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (UPLOAD + EXCEPT_LOGIC + fx) (Array Event)
decide
  { author, books, article }
  { id
  , legacyId
  , books: bookIds
  , author: authorId
  , theme
  , title
  , lead
  , notes
  , sources
  , content
  , illustrations: illustrationInputs
  , profitable
  , slug
  , magazineIssue
  } = checkAuthor
  where
  checkAuthor = case authorId, author of
    Just _, Just (Author.Referenced _) -> checkBooks
    Just authorId_, _ -> throw $ AuthorNotReferenced authorId_
    _, _ -> checkBooks

  checkBooks = do
    for_ bookIds \bId -> case Map.lookup bId books of
      Just (Book.Referenced _) -> ηι
      _ -> throw $ BookNotReferenced bId
    checkArticle

  checkArticle = case article of
    Article.Written _ -> throw ArticleAlreadyWritten

    _ -> do
      illustrations <-
        traverse
          ( \{ image: imageUrl, caption } -> do
              image <- Upload.uploadImage true true imageUrl
              η { image, caption }
          )
          illustrationInputs

      slug' <- case slug of
        Just providedSlug -> η providedSlug
        Nothing -> case make_ true (toString title) of
          Right generated -> η generated
          Left _ -> throw $ InvalidSlug (toString title)

      updatedContentStr <- Upload.uploadHtmlImages true (toString content)
      let updatedContent = Html.unsafeFromString updatedContentStr
      
      updatedLead <- traverse (\h -> Html.unsafeFromString <$> Upload.uploadHtmlImages true (toString h)) lead
      updatedNotes <- traverse (\h -> Html.unsafeFromString <$> Upload.uploadHtmlImages true (toString h)) notes
      updatedSources <- traverse (\h -> Html.unsafeFromString <$> Upload.uploadHtmlImages true (toString h)) sources

      η
        [ ArticleWritten
            { id
            , legacyId
            , books: bookIds
            , author: authorId
            , theme
            , title
            , lead: updatedLead
            , notes: updatedNotes
            , sources: updatedSources
            , content: updatedContent
            , illustrations
            , profitable
            , slug: slug'
            , magazineIssue
            }
        ]
