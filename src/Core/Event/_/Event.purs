module Core.Event.Event where

import Proem

import Control.Monad.Except as Control.Monad.Except
import Core.Event.ArticleAddedToNewsRelatedBlacklist.Payload as ArticleAddedToNewsRelatedBlacklist
import Core.Event.ArticleAddedToNewsRelatedWhitelist.Payload as ArticleAddedToNewsRelatedWhitelist
import Core.Event.ArticleDiscarded.Payload as ArticleDiscarded
import Core.Event.ArticleFeaturedOnFrontPage.Payload as ArticleFeaturedOnFrontPage
import Core.Event.ArticleQuoted.Payload as ArticleQuoted
import Core.Event.ArticleRead.Payload as ArticleRead
import Core.Event.ArticleRemovedFromNewsRelatedBlacklist.Payload as ArticleRemovedFromNewsRelatedBlacklist
import Core.Event.ArticleRemovedFromNewsRelatedWhitelist.Payload as ArticleRemovedFromNewsRelatedWhitelist
import Core.Event.ArticleWritten.Payload as ArticleWritten
import Core.Event.AuthorDereferenced.Payload as AuthorDereferenced
import Core.Event.AuthorReferenced.Payload as AuthorReferenced
import Core.Event.BookDereferenced.Payload as BookDereferenced
import Core.Event.BookReferenced.Payload as BookReferenced
import Core.Event.EditorDereferenced.Payload as EditorDereferenced
import Core.Event.EditorReferenced.Payload as EditorReferenced
import Core.Event.Id (EventId)
import Core.Event.MagazineCustomSectionAdded.Payload as MagazineCustomSectionAdded
import Core.Event.MagazineIssueDereferenced.Payload as MagazineIssueDereferenced
import Core.Event.MagazineIssueReferenced.Payload as MagazineIssueReferenced
import Core.Event.NewsTopicAdded.Payload as NewsTopicAdded
import Core.Event.NewsTopicRemoved.Payload as NewsTopicRemoved
import Core.Event.NewsletterScheduled.Payload as NewsletterScheduled
import Core.Event.UserDonated.Payload as UserDonated
import Core.Event.UserEmailChanged.Payload as UserEmailChanged
import Core.Event.UserRegistered.Payload as UserRegistered
import Core.Event.UserUnregistered.Payload as UserUnregistered
import Core.Mod.Id.Id as Id
import Core.Mod.Time.Instant (Instant)
import Core.Mod.Trace.Cause (CauseNode)
import Core.Mod.Trace.Id (AppendId, RunId)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.List.Types (NonEmptyList)
import Data.Maybe (Maybe)
import Data.Show.Generic (genericShow)
import Foreign (Foreign, ForeignError)
import Foreign.Object (lookup)
import Foreign.Object as Foreign.Object
import Partial.Unsafe (unsafeCrashWith)
import Util.Json.TaggedSum (genericReadImpl, genericWriteImpl)
import Util.Type.Row.Row (recordKeysMatch)
import Util.Type.Type (class Reflect)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)
import Yoga.JSON as JSON
import Yoga.JSON.Generics.TaggedSumRep as Tagged

data Event
  = AuthorReferenced AuthorReferenced.Payload
  | AuthorDereferenced AuthorDereferenced.Payload
  | BookReferenced BookReferenced.Payload
  | BookDereferenced BookDereferenced.Payload
  | MagazineIssueReferenced MagazineIssueReferenced.Payload
  | MagazineIssueDereferenced MagazineIssueDereferenced.Payload
  | EditorReferenced EditorReferenced.Payload
  | EditorDereferenced EditorDereferenced.Payload
  | UserEmailChanged UserEmailChanged.Payload
  | UserRegistered UserRegistered.Payload
  | UserUnregistered UserUnregistered.Payload
  | UserDonated UserDonated.Payload
  | ArticleDiscarded ArticleDiscarded.Payload
  | ArticleFeaturedOnFrontPage ArticleFeaturedOnFrontPage.Payload
  | ArticleWritten ArticleWritten.Payload
  | ArticleQuoted ArticleQuoted.Payload
  | NewsTopicAdded NewsTopicAdded.Payload
  | NewsTopicRemoved NewsTopicRemoved.Payload
  | ArticleAddedToNewsRelatedWhitelist ArticleAddedToNewsRelatedWhitelist.Payload
  | ArticleRemovedFromNewsRelatedWhitelist ArticleRemovedFromNewsRelatedWhitelist.Payload
  | ArticleAddedToNewsRelatedBlacklist ArticleAddedToNewsRelatedBlacklist.Payload
  | ArticleRemovedFromNewsRelatedBlacklist ArticleRemovedFromNewsRelatedBlacklist.Payload
  | ArticleRead ArticleRead.Payload
  | NewsletterScheduled NewsletterScheduled.Payload
  | MagazineCustomSectionAdded MagazineCustomSectionAdded.Payload

derive instance Generic Event _
derive instance Eq Event

instance Show Event where
  show = genericShow

class (Reflect event) <= IsEvent (event :: Type) (payload :: Type) | event -> payload

type WeakHeadEvent = { | WeakHeadEventRow }

type WeakHeadEventRow =
  ( type :: String
  , payload :: Foreign
  )

eventToWeakHead :: Event -> WeakHeadEvent
eventToWeakHead event = case Control.Monad.Except.runExcept (readImpl $ writeImpl event) of
  Left _ -> unsafeCrashWith "Unreachable: Event to WeakHeadEvent encoding failed"
  Right weakHead -> weakHead

weakHeadToEvent :: WeakHeadEvent -> Either (NonEmptyList ForeignError) Event
weakHeadToEvent weak = case Control.Monad.Except.runExcept (readImpl (writeImpl weak)) of
  Left err -> unsafeCrashWith $ "Failed to decode event: " <> weak.type <> ", payload: " <> JSON.writeJSON weak.payload <> " err: " <> show err
  Right ev -> Right ev

customOptions :: Tagged.Options
customOptions = Tagged.defaultOptions { valueTag = "payload" }

instance WriteForeign Event where
  writeImpl = genericWriteImpl customOptions

instance ReadForeign Event where
  readImpl = genericReadImpl customOptions

decodeEventPayloadJson :: String -> Foreign -> Either (NonEmptyList ForeignError) Event
decodeEventPayloadJson typ payload = 
  let obj = writeImpl { type: typ, payload: payload }
  in Control.Monad.Except.runExcept (readImpl obj)

type MetaTrace =
  { run :: RunId
  , append :: Maybe AppendId
  , cause :: Maybe CauseNode
  }

type Meta =
  { trace :: MetaTrace
  }

type AppendableEvent =
  { event :: Event
  , meta :: Meta
  }

type WeakHeadAppendableEvent =
  { event :: Foreign
  , meta :: Foreign
  }

type LoadedEvent =
  { sequenceNumber :: String
  , id :: EventId
  , at :: Instant
  , event :: Event
  , meta :: Meta
  }

type WeakHeadLoadedEvent =
  { sequenceNumber :: String
  , id :: String
  , at :: Instant
  , event :: Foreign
  , meta :: Foreign
  }

check :: Q ConstraintPredicate
check = do
  recordKeysMatch @AppendableEvent @WeakHeadAppendableEvent
  recordKeysMatch @LoadedEvent @WeakHeadLoadedEvent

appendableToWeakHead :: AppendableEvent -> WeakHeadAppendableEvent
appendableToWeakHead { event, meta } =
  let
    obj = Foreign.Object.empty
  in
    { meta: writeImpl meta
    , event: lookup (ᴠ'' @"event" @WeakHeadAppendableEvent) obj ??⇒ writeImpl event
    }

weakHeadToLoadedEvent :: WeakHeadLoadedEvent -> Either (NonEmptyList ForeignError) LoadedEvent
weakHeadToLoadedEvent { sequenceNumber, id, at, meta: meta_, event: event_ } = Control.Monad.Except.runExcept $ do
  event <- readImpl event_
  meta <- readImpl meta_

  η
    { sequenceNumber
    , id: Id.unsafeFromString id
    , at
    , event
    , meta
    }

