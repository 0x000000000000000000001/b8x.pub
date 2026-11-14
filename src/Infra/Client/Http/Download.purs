module Infra.Client.Http.Download where

import Proem

import Affjax.ResponseFormat as ResponseFormat
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Message.Command.Handle.Download (DOWNLOAD, Download(..), download')
import Core.Mod.Url.Exception (UrlCannotBeDownloaded(..))
import Data.Either (Either(..))
import Run (AFF, EFFECT, Run, interpret, on, send)
import Type.Row (type (+))
import Util.File.Docx as Docx
import Util.Http.Http as Http
import Util.Log.Error (error)
import Util.Type.String.ToString (toString)

interpretDownload
  :: ∀ fx a
   . Run (DOWNLOAD + EXCEPT_LOGIC + EFFECT + AFF + fx) a
  -> Run (EXCEPT_LOGIC + EFFECT + AFF + fx) a
interpretDownload = interpret (on download' handle send)
  where
  handle :: ∀ fx' a'. Download a' -> Run (EXCEPT_LOGIC + EFFECT + AFF + fx') a'
  handle (DownloadText url next) = do
    res <- ʌ' $ Http.getCheckStatus ResponseFormat.string (toString url)
    case res of
      Left err -> do
        error $ "DownloadText exception for " <> toString url <> ": " <> err
        throw $ UrlCannotBeDownloaded (toString url)
      Right { body } -> η $ next body
  handle (DownloadDocx url next) = do
    res <- ʌ' $ Http.getCheckStatus ResponseFormat.arrayBuffer (toString url)
    case res of
      Left err -> do
        error $ "DownloadDocx exception for " <> toString url <> ": " <> err
        throw $ UrlCannotBeDownloaded (toString url)
      Right { body } -> do
        html <- ʌ' $ Docx.docxToHtml body
        case html of
          Left err -> do
            error $ "Docx conversion exception for " <> toString url <> ": " <> show err
            throw $ UrlCannotBeDownloaded (toString url)
          Right content -> η $ next content
