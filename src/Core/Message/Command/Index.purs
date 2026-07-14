module Core.Message.Command.Index
  ( Command(..)
  , CommandRow
  , WeakHeadCommand
  , WeakHeadCommandRow
  , class FindCommandLabel
  ) where

import Proem

import Core.Feat.Membership.Message.Command.Index (MembershipCommandRow)
import Core.Feat.Newsletter.Message.Command.Index (NewsletterCommandRow)
import Core.Feat.Reference.Message.Command.Index (ReferenceCommandRow)
import Core.Feat.Review.Message.Command.Index (ReviewCommandRow)
import Foreign (Foreign)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)
import Data.Variant (Variant)
import Prim.RowList (Cons, RowList)
import Type.Row (type (+))
import Util.Type.String.String (Case(..))
import Util.Type.Variant.Encoding.Encoding (Encoding, decodeJsonWith', defaultEncoding, encodeJsonWith')

newtype Command = Command (Variant CommandRow)

derive instance Newtype Command _

type CommandRow =
  MembershipCommandRow
    + ReferenceCommandRow
    + ReviewCommandRow
    + NewsletterCommandRow
    + ()

type WeakHeadCommand = { | WeakHeadCommandRow }

type WeakHeadCommandRow =
  ( type :: String
  , payload :: Foreign
  )

encoding :: Encoding
encoding =
  defaultEncoding
    { tag = defaultEncoding.tag { case = Pascal }
    , valueKey = ᴠ' @"payload" @WeakHeadCommandRow
    }

instance WriteForeign Command where
  writeImpl = encodeJsonWith' encoding

instance ReadForeign Command where
  readImpl = decodeJsonWith' encoding

class FindCommandLabel (cmd :: Type) (rowList :: RowList Type) (label :: Symbol) | cmd rowList -> label

instance FindCommandLabel cmd (Cons label cmd tail) label
else instance FindCommandLabel cmd tail label => FindCommandLabel cmd (Cons sym other tail) label
