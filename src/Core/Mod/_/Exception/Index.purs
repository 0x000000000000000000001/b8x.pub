module Core.Mod.Exception.Index where

import Core.Mod.Array.Exception (ArrayExceptionRow)
import Core.Mod.Article.Exception.Index (ArticleExceptionRow)
import Core.Mod.Author.Exception.Index (AuthorExceptionRow)
import Core.Mod.Book.Exception.Index (BookExceptionRow)
import Core.Mod.Boolean.Exception (BooleanExceptionRow)
import Core.Mod.Editor.Exception.Index (EditorExceptionRow)
import Core.Mod.Email.Exception (EmailExceptionRow)
import Core.Mod.Html.Exception (HtmlExceptionRow)
import Core.Mod.Id.Exception (IdExceptionRow)
import Core.Mod.Image.Exception.Index (ImageExceptionRow)
import Core.Mod.Int.Exception (IntExceptionRow)
import Core.Mod.NonEmptyString.Exception (NonEmptyStringExceptionRow)

import Core.Mod.Token.Exception (TokenExceptionRow)
import Core.Mod.Url.Exception (UrlExceptionRow)
import Core.Mod.User.Exception.Index (UserExceptionRow)
import Core.Mod.NewsTopic.Exception.Index (NewsTopicExceptionRow)
import Core.Mod.MagazineIssue.Exception.Index (MagazineIssueExceptionRow)
import Core.Mod.Newsletter.Exception.Index (NewsletterExceptionRow)
import Core.Mod.RateLimit.Exception.Index (RateLimitExceptionRow)
import Core.Mod.Time.Exception (TimeExceptionRow)
import Type.Row (type (+))

type ModExceptionRow r =
  ArrayExceptionRow
    + AuthorExceptionRow
    + BookExceptionRow
    + BooleanExceptionRow
    + EditorExceptionRow
    + EmailExceptionRow
    + HtmlExceptionRow
    + IdExceptionRow
    + ImageExceptionRow
    + IntExceptionRow
    + NonEmptyStringExceptionRow
    + UserExceptionRow
    + ArticleExceptionRow
    + TokenExceptionRow
    + UrlExceptionRow
    + NewsTopicExceptionRow
    + MagazineIssueExceptionRow
    + NewsletterExceptionRow
    + RateLimitExceptionRow
    + TimeExceptionRow
    + r