module Core.Feat.Review.Message.Command.WriteArticle.Payload where

import Core.Feat.Review.Message.Command.WriteArticle.Field.Author (AuthorField)
import Core.Mod.Article.Author.Author (Author)
import Core.Feat.Review.Message.Command.WriteArticle.Field.ContentUrl (ContentUrl, ContentUrlField)
import Core.Mod.Article.Id.Message.Field.AutoId (Id, IdField)
import Core.Mod.Article.Illustrations.Inputs.Message.Field (Inputs, InputsField)
import Core.Mod.Article.Lead.Message.Field (Lead, LeadField)
import Core.Mod.Article.LegacyId.Message.Field (LegacyId, LegacyIdField)
import Core.Feat.Review.Message.Command.WriteArticle.Field.NotesUrl (NotesUrl, NotesUrlField)
import Core.Mod.Article.Sources.Message.Field (Sources, SourcesField)
import Core.Mod.Article.Slug.Message.Field.MaybeSlug (SlugField, Slug)
import Core.Mod.Article.Theme.Message.Field.MaybeTheme (Theme, ThemeField)
import Core.Mod.Article.Title.Message.Field (Title, TitleField)
import Core.Mod.Book.Id.Message.Field.Books as Base
import Core.Mod.Article.FrontPage.Position.Message.Field.MaybePosition (Position, PositionField)

type Books = Base.Books
type BooksField = Base.BooksField

type Payload =
  { id :: Id
  , legacyId :: LegacyId
  , books :: Books
  , author :: Author
  , theme :: Theme
  , title :: Title
  , lead :: Lead
  , notes :: NotesUrl
  , sources :: Sources
  , content :: ContentUrl
  , illustrations :: Inputs
  , slug :: Slug
  -- , profitable :: Profitable
  -- , magazineIssue :: MagazineIssue
  , frontPagePosition :: Position
  }

type Fields =
  ( id :: IdField
  , legacyId :: LegacyIdField
  , books :: BooksField
  , author :: AuthorField
  , theme :: ThemeField
  , title :: TitleField
  , lead :: LeadField
  , notes :: NotesUrlField
  , sources :: SourcesField
  , content :: ContentUrlField
  , illustrations :: InputsField
  , slug :: SlugField
  -- , profitable :: ProfitableField
  -- , magazineIssue :: MagazineIssueField
  , frontPagePosition :: PositionField
  )
