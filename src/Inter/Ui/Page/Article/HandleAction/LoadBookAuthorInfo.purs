module Inter.Ui.Page.Article.HandleAction.LoadBookAuthorInfo
  ( loadBookAuthorInfo
  ) where

import Proem

import Core.Feat.Reference.Message.Query.GetAuthor.Field.Needs as GetAuthorNeeds
import Core.Feat.Reference.Message.Query.GetAuthor.Query (GetAuthor(..))
import Core.Feat.Reference.Message.Query.GetAuthor.Result (Author) as GetAuthor
import Core.Message.Query.Payload (Need(..))
import Core.Message.Query.Result (Return(..))
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Html.Html (NonEmptyHtml)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Halogen (gets, modify_)
import Inter.Ui.Page.Article.Type (ArticleM)
import Inter.Ui.Remote (query)
import Inter.Ui.Type.Device (Device(..))
import Inter.Ui.Type.Model (UiAuthorInfo)
import Inter.Ui.Type.Remote (Remote)
import Network.RemoteData (RemoteData(..))
import Util.Html.Clean.Render.Render (SanitizedHtmlString, sanitizeHtml)
import Util.Html.Clean.Render.WpAutop.WpAutop (wpAutop)

authorInfoNeeds :: GetAuthorNeeds.Needs
authorInfoNeeds = GetAuthorNeeds.defaultNeeds
  { biography = Needed ι ι
  , portrait = Needed ι
      { src: Needed { absolute: true } ι
      , dimensions: Needed ι { width: Needed ι ι, height: Needed ι ι }
      }
  }

loadBookAuthorInfo :: AuthorId -> ArticleM Ɩ
loadBookAuthorInfo id = do
  state <- gets identity
  case state.context, Map.lookup id state.bookAuthorInfos of
    Desktop, Just (Success _) -> ηι
    Desktop, Just Loading -> ηι
    Desktop, _ -> fetch
    _, _ -> ηι
  where
  fetch :: ArticleM Ɩ
  fetch = do
    modify_ \s -> s { bookAuthorInfos = Map.insert id Loading s.bookAuthorInfos }
    res <- query (GetAuthor { id, needs: authorInfoNeeds })
    modify_ \s -> s { bookAuthorInfos = Map.insert id (toRemoteInfo res) s.bookAuthorInfos }

toRemoteInfo :: Remote (Maybe GetAuthor.Author) -> Remote UiAuthorInfo
toRemoteInfo = case _ of
  Success (Just author) -> Success (toAuthorInfo author)
  Success Nothing -> Success { biography: Nothing, portrait: Nothing }
  Failure err -> Failure err
  Loading -> Loading
  NotAsked -> NotAsked

toAuthorInfo :: GetAuthor.Author -> UiAuthorInfo
toAuthorInfo author =
  { biography: case author.biography of
      Given (Just biography) -> Just (cleanWpNonEmpty biography)
      _ -> Nothing
  , portrait: case author.portrait of
      Given portrait -> portrait
      _ -> Nothing
  }

cleanWpNonEmpty :: NonEmptyHtml -> SanitizedHtmlString
cleanWpNonEmpty c = sanitizeHtml (wpAutop false (unwrap c))
