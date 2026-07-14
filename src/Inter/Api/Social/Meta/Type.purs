module Inter.Api.Social.Meta.Type where

import Data.Maybe (Maybe(..))

type Meta =
  { title :: Maybe String
  , description :: Maybe String
  , image :: Maybe String
  }

defaultTitle :: String
defaultTitle = "Books"

defaultDescription :: String
defaultDescription = "Books, le magazine qui éclaire l'actualité par les livres du monde entier. Résiste à la mode et à la pensée facile."

defaultMeta :: Meta
defaultMeta =
  { title: Just defaultTitle
  , description: Just defaultDescription
  , image: Nothing
  }
