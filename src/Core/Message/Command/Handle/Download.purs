module Core.Message.Command.Handle.Download
  ( DOWNLOAD
  , Download(..)
  , interpretDownloadWithMock
  , download'
  , downloadDocx
  , downloadHtml
  , downloadText
  ) where

import Proem

import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Mod.Url.Url (Url, isDocxUrl)
import Run (Run, interpret, lift, on, send)
import Type.Row (type (+))

data Download a
  = DownloadText Url (String -> a)
  | DownloadDocx Url (String -> a)

derive instance Functor Download

type DOWNLOAD fx = (download :: Download | fx)

download' = π :: Π "download"

downloadText :: ∀ fx. Url -> Run (DOWNLOAD + fx) String
downloadText url = lift download' (DownloadText url identity)

downloadDocx :: ∀ fx. Url -> Run (DOWNLOAD + fx) String
downloadDocx url = lift download' (DownloadDocx url identity)

-- | Downloads content as HTML, converting `.docx` documents on the fly.
downloadHtml :: ∀ fx. Url -> Run (DOWNLOAD + fx) String
downloadHtml url = isDocxUrl url ? downloadDocx url ↔ downloadText url

interpretDownloadWithMock
  :: ∀ fx a
   . Run (DOWNLOAD + EXCEPT_LOGIC + fx) a
  -> Run (EXCEPT_LOGIC + fx) a
interpretDownloadWithMock = interpret (on download' handle send)
  where
  handle :: ∀ fx' a'. Download a' -> Run (EXCEPT_LOGIC + fx') a'
  handle (DownloadText _ next) = do
    η $ next "Mock fetched text"
  handle (DownloadDocx _ next) = do
    η $ next "Mock fetched html"
