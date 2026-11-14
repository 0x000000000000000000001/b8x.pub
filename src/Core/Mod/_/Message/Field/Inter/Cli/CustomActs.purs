module Core.Mod.Message.Field.Inter.Cli.CustomActs where

import Core.Mod.Message.Field.Inter.Cli.Type (CustomCliAct)
import Data.Maybe (Maybe(..))
import Core.Mod.Article.Author.Inter.Cli (askAuthor)
import Core.Mod.Book.Inter.Cli (askBook)
import Core.Mod.Editor.Inter.Cli (askEditor)
import Core.Mod.Article.Inter.Cli (askArticle)
import Core.Mod.NewsTopic.Inter.Cli (askNewsTopic)
import Core.Mod.Newsletter.Inter.Cli (askNewsletter)
import Core.Feat.Review.Message.Command.WriteArticle.Field.Author as WriteArticleAuthor
import Core.Mod.Article.Author.Message.Field as BaseAuthor
import Core.Mod.Article.Id.Message.Field.Article as ArticleField
import Core.Mod.Author.Id.Message.Field.Author as AuthorIdField
import Core.Mod.Author.Id.Message.Field.Authors as AuthorsField
import Core.Mod.Book.Id.Message.Field.Books as BooksField
import Core.Mod.Editor.Id.Message.Field.MaybeEditor as EditorField
import Core.Mod.Newsletter.Id.Message.Field.Id as NewsletterIdField
import Core.Mod.Newsletter.Articles.Message.Field as NewsletterArticlesField
import Core.Mod.Newsletter.ScheduledFor.Message.Field as ScheduledForField
import Core.Mod.NewsTopic.Id.Message.Field.NewsTopic as NewsTopicField
import Core.Mod.Time.Message.Field.Instant as InstantField
import Core.Mod.Time.Inter.Cli (askParisTime)

class HasCustomCliAct :: ∀ k. k -> Constraint
class HasCustomCliAct field where
  getCustomCliAct :: ∀ fx. Maybe (CustomCliAct fx)

instance HasCustomCliAct WriteArticleAuthor.AuthorField where
  getCustomCliAct = Just (askAuthor "article")
else instance HasCustomCliAct BaseAuthor.AuthorField where
  getCustomCliAct = Just (askAuthor "")
else instance HasCustomCliAct AuthorsField.AuthorsField where
  getCustomCliAct = Just (askAuthor "")
else instance HasCustomCliAct BooksField.BooksField where
  getCustomCliAct = Just askBook
else instance HasCustomCliAct EditorField.EditorField where
  getCustomCliAct = Just askEditor
else instance HasCustomCliAct NewsletterArticlesField.ArticlesField where
  getCustomCliAct = Just askArticle
else instance HasCustomCliAct NewsletterIdField.NewsletterIdField where
  getCustomCliAct = Just askNewsletter
else instance HasCustomCliAct ArticleField.ArticleField where
  getCustomCliAct = Just askArticle
else instance HasCustomCliAct AuthorIdField.AuthorField where
  getCustomCliAct = Just (askAuthor "")
else instance HasCustomCliAct NewsTopicField.NewsTopicField where
  getCustomCliAct = Just askNewsTopic
else instance HasCustomCliAct ScheduledForField.ScheduledForField where
  getCustomCliAct = Just askParisTime
else instance HasCustomCliAct InstantField.InstantField where
  getCustomCliAct = Just askParisTime
else instance HasCustomCliAct any where
  getCustomCliAct = Nothing
