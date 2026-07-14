module Util.Env
  (Env(..)
  ) where

import Proem

import Yoga.JSON (class ReadForeign, readImpl)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Util.Lexicon.Prod (prod_)
import Util.Type.String.String (lowerCaseFirst)

data Env = Dev | Prod

derive instance Eq Env
derive instance Generic Env _

instance Show Env where
  show = lowerCaseFirst ◁ genericShow

instance ReadForeign Env where
  readImpl json = do
    str <- readImpl @String json
    η case str of
      _ | prod_ == str -> Prod
      _ -> Dev
