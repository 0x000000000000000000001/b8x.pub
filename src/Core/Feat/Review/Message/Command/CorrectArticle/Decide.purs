module Core.Feat.Review.Message.Command.CorrectArticle.Decide where

import Proem

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Review.Message.Command.CorrectArticle.Payload (Payload)
import Core.Feat.Review.Message.Command.CorrectArticle.State (ArticleData, State)
import Core.Message.Command.Corrected (Corrected(..))
import Core.Message.Command.Handle.Download (DOWNLOAD)
import Core.Message.Command.Handle.Download as Download
import Core.Message.Command.Handle.Upload (UPLOAD)
import Core.Message.Command.Handle.Upload as Upload
import Core.Mod.Article.Content.Content (Content)
import Core.Mod.Article.Exception.ArticleNotWritten (ArticleNotWritten(..))
import Core.Mod.Article.State as Article
import Core.Mod.Html.Html as Html
import Core.Mod.Url.Url (Url)
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (DOWNLOAD + UPLOAD + EXCEPT_LOGIC + fx) (Array Event)
decide
  { article }
  { id, title: titleCorrection, content: contentCorrection } = checkArticle
  where
  checkArticle :: Run (DOWNLOAD + UPLOAD + EXCEPT_LOGIC + fx) (Array Event)
  checkArticle = case article of
    Article.Written current -> do
      titleEvent <- evaluateTitle current
      contentEvent <- evaluateContent current
      η $ Array.catMaybes [ titleEvent, contentEvent ]
    _ -> throw $ ArticleNotWritten id

  evaluateTitle :: ArticleData -> Run (DOWNLOAD + UPLOAD + EXCEPT_LOGIC + fx) (Maybe Event)
  evaluateTitle { title: currentTitle } = case titleCorrection of
    AsIs -> η Nothing
    Corrected title ->
      η $ currentTitle == title ? Nothing ↔ Just (ArticleTitleCorrected { article: id, title })

  evaluateContent :: ArticleData -> Run (DOWNLOAD + UPLOAD + EXCEPT_LOGIC + fx) (Maybe Event)
  evaluateContent { content: currentContent } = case contentCorrection of
    AsIs -> η Nothing
    Corrected url -> do
      content <- fetchContent url
      η $ currentContent == content ? Nothing ↔ Just (ArticleContentCorrected { article: id, content })

  fetchContent :: Url -> Run (DOWNLOAD + UPLOAD + EXCEPT_LOGIC + fx) Content
  fetchContent url = do
    fetched <- Download.downloadHtml url
    uploaded <- Upload.uploadHtmlImages true fetched
    Html.make uploaded
