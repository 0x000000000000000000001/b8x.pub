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
import Data.Traversable (traverse)
import Run (Run)
import Type.Row (type (+))
import Util.Type.String.ToString (toString)

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (DOWNLOAD + UPLOAD + EXCEPT_LOGIC + fx) (Array Event)
decide
  { article }
  { id, title: titleCorrection, lead: leadCorrection, content: contentCorrection } = checkArticle
  where
  checkArticle :: Run (DOWNLOAD + UPLOAD + EXCEPT_LOGIC + fx) (Array Event)
  checkArticle = case article of
    Article.Written current -> do
      titleEvent <- evaluateTitle current
      leadEvent <- evaluateLead current
      contentEvent <- evaluateContent current
      η $ Array.catMaybes [ titleEvent, leadEvent, contentEvent ]
    _ -> throw $ ArticleNotWritten id

  evaluateTitle :: ArticleData -> Run (DOWNLOAD + UPLOAD + EXCEPT_LOGIC + fx) (Maybe Event)
  evaluateTitle { title: currentTitle } = case titleCorrection of
    AsIs -> η Nothing
    Corrected title ->
      η $ currentTitle == title ? Nothing ↔ Just (ArticleTitleCorrected { article: id, title })

  evaluateLead :: ArticleData -> Run (DOWNLOAD + UPLOAD + EXCEPT_LOGIC + fx) (Maybe Event)
  evaluateLead { lead: currentLead } = case leadCorrection of
    AsIs -> η Nothing
    Corrected lead -> do
      correctedLead <- traverse uploadLeadHtml lead
      η $ currentLead == correctedLead ? Nothing ↔ Just (ArticleLeadCorrected { article: id, lead: correctedLead })

  uploadLeadHtml :: Html.NonEmptyHtml -> Run (DOWNLOAD + UPLOAD + EXCEPT_LOGIC + fx) Html.NonEmptyHtml
  uploadLeadHtml lead =
    Html.unsafeFromString <$> Upload.uploadHtmlImages true (toString lead)

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
