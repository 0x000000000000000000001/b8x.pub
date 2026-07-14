module Inter.Api.Registry where


import Proem

import Core.Message.Command.Command (class IsCommand)
import Core.Message.Command.Handle.Handle (handleCommand)
import Core.Message.Command.Make (makeCommand)
import Core.Message.Field.Payload (class MakePayload)
import Core.Message.Query.Make (makeQuery)
import Core.Message.MakeMessageM (liftMakeMessageM)
import Core.Message.Query.Query (class IsQuery)
import Core.Message.Query.Query as Query
import Core.Message.Message (Message(..))
import Inter.Api.Route (Route(..), routeCodec) as ApiRoute
import Inter.Api.Whitelist.Command (CommandRow)
import Inter.Api.Whitelist.Query (QueryRow)
import Inter.Api.Middleware.Auth (getSubject)
import Core.Mod.Id.Id as Id
import Core.Mod.Trace.Cause as CauseNode
import Foreign (Foreign)
import Foreign as Foreign
import Util.Foreign.Native as Util.Foreign.Native
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl, E, unsafeStringify)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), isJust, fromMaybe)
import Data.Tuple.Nested ((/\))
import Data.Array (last) as Array
import Data.String (Pattern(..), split, stripPrefix, stripSuffix) as String
import Data.Newtype (unwrap)
import Data.Symbol (class IsSymbol)
import Effect.Aff (Aff, makeAff, nonCanceler, try)
import Effect.Exception (message)
import Effect.Ref as Ref
import Foreign.Object (Object)
import Foreign.Object as Object
import Inter.Api.ApiM (ApiM, Context, runApiM)
import Node.Encoding (Encoding(..))
import Node.EventEmitter (on_)
import Node.HTTP.IncomingMessage as IncomingMessage
import Node.HTTP.OutgoingMessage (setHeader, toWriteable)
import Node.HTTP.ServerResponse (setStatusCode, toOutgoingMessage)
import Node.HTTP.Types (IMServer, IncomingMessage, ServerResponse)
import Node.Stream (dataHStr, end, endH, setEncoding, writeString)
import Prim.Row as Row
import Prim.RowList (class RowToList, Cons)
import Util.Crypto.Hash (xxhash64)
import Util.I18n (Language(..), translate)
import Util.Type.Row.Registry (class RegistryBuilder, buildRegistryFromRowList)
import Util.Type.String.String (caseToKebab, caseToPascal)
import Routing.Duplex (print)
import Util.Type.String.ToString (toString)
import Util.Type.Type (class Reflect, reflectName, reflectVariantKeyName)

type Handler = Context -> IncomingMessage IMServer -> ServerResponse -> Aff Ɩ

registry :: Object Handler
registry =
  (buildRegistry @Commands @CommandRow)
    `Object.union` (buildRegistry @Queries @QueryRow)

class BuildRegistry (section :: Type) (row :: Row Type) where
  buildRegistry :: Object Handler

instance
  ( RowToList row rowList
  , RegistryBuilder section rowList Handler
  ) =>
  BuildRegistry section row where
  buildRegistry = buildRegistryFromRowList @section @rowList

-- Commands

data Commands

class SerializeCommandResult a where
  serializeCommandResult :: a -> Foreign.Foreign

instance SerializeCommandResult Unit where
  serializeCommandResult _ = writeImpl {}
else instance WriteForeign a => SerializeCommandResult a where
  serializeCommandResult a = writeImpl a

instance
  ( IsSymbol cmdName
  , IsCommand cmd state fields payload a
  , Reflect cmd
  , SerializeCommandResult a
  , MakePayload fields payload
  , RegistryBuilder Commands tail Handler
  , Row.Cons cmdName cmd commandRowTail CommandRow
  ) =>
  RegistryBuilder Commands (Cons cmdName cmd tail) Handler where
  buildRegistryFromRowList =
    let
      tailRegistry = buildRegistryFromRowList @Commands @tail
      cmdName = reflectName @cmd

      routeUrl = print ApiRoute.routeCodec (ApiRoute.Write (cmdName # caseToKebab))

      handler ctx req res = handleMessage Command cmdName ctx req res serializeCommandResult (const $ η Nothing) \obj -> do
        cmd <- liftMakeMessageM (makeCommand @cmd obj)
        handleCommand @cmd true cmd
    in
      Object.insert routeUrl handler tailRegistry

-- Queries

data Queries

instance
  ( IsSymbol queryName
  , IsQuery query state fields payload a
  , Reflect query
  , ReadForeign a
  , WriteForeign a
  , MakePayload fields payload
  , RegistryBuilder Queries tail Handler
  , Row.Cons queryName query queryRowTail QueryRow
  ) =>
  RegistryBuilder Queries (Cons queryName query tail) Handler where
  buildRegistryFromRowList =
    let
      tailRegistry = buildRegistryFromRowList @Queries @tail
      queryName = reflectName @query

      routeUrl = print ApiRoute.routeCodec (ApiRoute.Read (queryName # caseToKebab))

      handler ctx req res = handleMessage Query queryName ctx req res writeImpl
        (\obj -> do
          query <- liftMakeMessageM (makeQuery @query obj)
          strategy <- Query.cacheStrategy query
          case strategy of
            Query.Cached { invalidationVersion } -> η (Just $ unsafeStringify invalidationVersion)
            Query.NotCached -> η Nothing
        )
        (\obj -> do
          query <- liftMakeMessageM (makeQuery @query obj)
          Query.handleWithCache query
        )
    in
      Object.insert routeUrl handler tailRegistry

handleMessage
  :: ∀ a
   . Message
  -> String
  -> Context
  -> IncomingMessage IMServer
  -> ServerResponse
  -> (a -> Foreign.Foreign)
  -> (Object Foreign -> ApiM (Maybe String))
  -> (Object Foreign -> ApiM a)
  -> Aff Ɩ
handleMessage type_ name ctx req res serializeResult fastEtag makeHandle = do
  bodyResult <- readBody req <#> Util.Foreign.Native.parseJSON

  case bodyResult of
    Left e -> respondUnknown req res e

    Right payload -> case (runExcept (readImpl payload) :: E (Object Foreign)) of
      Left _ -> respondUnknown req res "Payload is not an object"

      Right obj -> do
        let xAppIdForStash = Object.lookup "x-app-id" (IncomingMessage.headers req)
        mOverriddenAt <-
          if xAppIdForStash == Just "InitialMigration" then do
            case Object.lookup "_at_01krp30973x3fezfn5zrcnqyz1" obj of
              Just atJson -> case (runExcept (readImpl atJson) :: E String) of
                Right atStr -> η (Just atStr)
                Left _ -> η Nothing
              Nothing -> η Nothing
          else η Nothing

        let mClientCommandId = Object.lookup "x-command-id" (IncomingMessage.headers req)
        runId <- case mClientCommandId of
          Just cid -> η (Id.unsafeFromString cid)
          Nothing -> ʌ Id.generate

        mSubject <- try $ getSubject ctx req
        let
          subject = case mSubject of
            Left _ -> Nothing
            Right s -> Just s

        traceContext <- case type_ of
          Command -> do
            let cause = { run: runId, append: Nothing, cause: Just (CauseNode.Command { run: runId, subject, name, cause: Nothing }), overriddenAt: mOverriddenAt }
            η cause
          _ -> do
            let cause = { run: runId, append: Nothing, cause: Just (CauseNode.Query { run: runId, subject, name }), overriddenAt: mOverriddenAt }
            η cause

        case mSubject of
          Left err | message err == "Token expired" || message err == "Invalid or missing CSRF token" || message err == "Token revoked (global logout)" || message err == "Missing X-App-Id" || message err == "Invalid or refused X-App-Id" ->
            respondUnauthorized req res (message err)
          Left err | message err /= "No session token provided" ->
            respondUnknown req res (message err)
          _ -> do

            mFastEtagResult <- try $ runApiM ctx traceContext $ fastEtag obj
            mRawEtag <- case mFastEtagResult of
              Right (Right (Just etagRawStr)) -> do
                hash <- xxhash64 etagRawStr
                pure (Just hash)
              _ -> pure Nothing
            let mFastEtagRaw = (\e -> "\"" <> e <> "\"") <$> mRawEtag

            let
              clientEtag = Object.lookup "if-none-match" (IncomingMessage.headers req)
              cleanEtag s =
                let
                  s1 = fromMaybe s (String.stripPrefix (String.Pattern "W/") s)
                  s2 = fromMaybe s1 (String.stripPrefix (String.Pattern "w/") s1)
                  s3 = fromMaybe s2 do
                    s2' <- String.stripPrefix (String.Pattern "\"") s2
                    String.stripSuffix (String.Pattern "\"") s2'
                in
                  s3

            if isJust mRawEtag && (cleanEtag <$> clientEtag) == mRawEtag then ʌ do
              setStatusCode 304 res
              let msg = toOutgoingMessage res
              setHeader "ETag" (fromMaybe "" mFastEtagRaw) msg
              end (toWriteable msg)
            else do

              resEitherEither <- try $ runApiM ctx traceContext $ makeHandle obj

              case resEitherEither of
                Left err -> respondUnknown req res $ message err

                Right resEither -> case resEither of
                  Left e -> do
                    let
                      objErr :: Object.Object Foreign.Foreign
                      objErr = Object.fromFoldable
                        [ "success" /\ writeImpl false
                        , "error" /\ writeImpl { type: caseToPascal $ extractErrorCode $ reflectVariantKeyName $ unwrap e, message: translate En e }
                        , "meta" /\ writeImpl { debug: Object.singleton (toString type_) (writeImpl { name, payload }) }
                        ]
                    respondRaw type_ req res mFastEtagRaw (unsafeStringify (Foreign.unsafeToForeign objErr))

                  Right result -> do
                    let
                      objSucc :: Object.Object Foreign.Foreign
                      objSucc = Object.fromFoldable
                        [ "success" /\ writeImpl true
                        , "data" /\ serializeResult result
                        , "meta" /\ writeImpl { debug: Object.singleton (toString type_) (writeImpl { name, payload }) }
                        ]
                    respondRaw type_ req res mFastEtagRaw (unsafeStringify (Foreign.unsafeToForeign objSucc))

respondUnknown :: IncomingMessage IMServer -> ServerResponse -> String -> Aff Ɩ
respondUnknown req res err =
  sendJson Nothing Nothing req res 500
    { success: false
    , error:
        { type: "Unknown"
        , message: err
        }
    }

respondUnauthorized :: IncomingMessage IMServer -> ServerResponse -> String -> Aff Ɩ
respondUnauthorized req res err =
  sendJson Nothing Nothing req res 401
    { success: false
    , error:
        { type: "Unauthorized"
        , message: err
        }
    }

respondRaw :: Message -> IncomingMessage IMServer -> ServerResponse -> Maybe String -> String -> Aff Ɩ
respondRaw type_ req res mFastEtag responseString = do
  let statusCode = 200
  case type_ of
    Query -> do
      etag <- case mFastEtag of
        Just e -> pure e
        Nothing -> do
          hash <- xxhash64 responseString
          pure ("\"" <> hash <> "\"")
      let
        clientEtag = Object.lookup "if-none-match" (IncomingMessage.headers req)
      ʌ do
        if clientEtag == Just etag || clientEtag == Just ("W/" <> etag) then do
          setStatusCode 304 res
          let msg = toOutgoingMessage res
          setHeader "ETag" etag msg
          end (toWriteable msg)
        else do
          setStatusCode statusCode res
          let msg = toOutgoingMessage res
          setHeader "Content-Type" "application/json" msg
          setHeader "ETag" etag msg
          ø $ writeString (toWriteable msg) UTF8 responseString
          end (toWriteable msg)
    _ -> ʌ do
      setStatusCode statusCode res
      let msg = toOutgoingMessage res
      setHeader "Content-Type" "application/json" msg
      ø $ writeString (toWriteable msg) UTF8 responseString
      end (toWriteable msg)

respond :: ∀ a. WriteForeign a => Message -> IncomingMessage IMServer -> ServerResponse -> a -> Aff Ɩ
respond type_ req res a = sendJson (Just type_) Nothing req res 200 a

sendJson :: ∀ a. WriteForeign a => Maybe Message -> Maybe String -> IncomingMessage IMServer -> ServerResponse -> Int -> a -> Aff Ɩ
sendJson mType mFastEtag req res statusCode a = do
  let responseString = unsafeStringify $ writeImpl a

  case mType of
    Just Query -> do
      etag <- case mFastEtag of
        Just e -> pure e
        Nothing -> do
          hash <- xxhash64 responseString
          pure ("\"" <> hash <> "\"")

      let
        clientEtag = Object.lookup "if-none-match" (IncomingMessage.headers req)

      ʌ do
        if clientEtag == Just etag || clientEtag == Just ("W/" <> etag) then do
          setStatusCode 304 res
          let msg = toOutgoingMessage res
          setHeader "ETag" etag msg
          end (toWriteable msg)
        else do
          setStatusCode statusCode res
          let msg = toOutgoingMessage res
          setHeader "Content-Type" "application/json" msg
          setHeader "ETag" etag msg
          ø $ writeString (toWriteable msg) UTF8 responseString
          end (toWriteable msg)
    _ -> ʌ do
      setStatusCode statusCode res
      let msg = toOutgoingMessage res
      setHeader "Content-Type" "application/json" msg
      ø $ writeString (toWriteable msg) UTF8 responseString
      end (toWriteable msg)

readBody :: IncomingMessage IMServer -> Aff String
readBody req = makeAff \resolve -> do
  let stream = IncomingMessage.toReadable req
  setEncoding stream UTF8
  ref <- Ref.new ""
  stream # on_ dataHStr \chunk -> do
    Ref.modify_ (\acc -> acc <> chunk) ref
  stream # on_ endH do
    result <- Ref.read ref
    resolve (Right result)
  η nonCanceler

extractErrorCode :: String -> String
extractErrorCode s = Array.last (String.split (String.Pattern ".") s) ??⇒ s
