module Core.Mod.Trace.Subject
  ( HttpRow
  , Subject(..)
  ) where

import Proem

import Core.Mod.User.Id.Id (UserId)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe)
import Util.Json.TaggedSum (genericReadImplWithDefaultOpt, genericWriteImplWithDefaultOpt)
import Yoga.JSON (class ReadForeign, class WriteForeign)

type HttpRow r =
  ( ip :: Maybe String
  , agent :: Maybe String
  | r
  )

data Subject
  = AnonymousUiHuman { | HttpRow () }
  | IdentifiedUiHuman { | HttpRow (userId :: UserId) }
  | InternetCrawler { | HttpRow () }
  | CliAdmin
  | InnerSystem { where :: String }
  | ThirdPartyWebhook { thirdParty :: String | HttpRow () }
  | InitialMigration { | HttpRow () }
  | Unknown { | HttpRow () }

derive instance Generic Subject _
derive instance Eq Subject

instance WriteForeign Subject where
  writeImpl = genericWriteImplWithDefaultOpt

instance ReadForeign Subject where
  readImpl = genericReadImplWithDefaultOpt

