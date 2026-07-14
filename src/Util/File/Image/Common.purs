module Util.File.Image.Common where

import Proem

import Data.Array (filter, snoc)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), drop, indexOf, joinWith, split, take)

mockImageUrl :: String
mockImageUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/011_The_lion_king_Tryggve_in_the_Serengeti_National_Park_Photo_by_Giles_Laurent.jpg/960px-011_The_lion_king_Tryggve_in_the_Serengeti_National_Park_Photo_by_Giles_Laurent.jpg"

transparentPlaceholder :: String
transparentPlaceholder = "data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs="

-- | Adds a version query parameter to an image URL.
-- |
-- | ```purescript
-- | >>> versioned "1.2.0" "https://this.is/link/to/image.png"
-- | "https://this.is/link/to/image.png?v=1.2.0"
-- |
-- | >>> versioned "1.2.3" "/link/to/image.png?v=1.2.0"
-- | "/link/to/image.png?v=1.2.3"
-- |
-- | >>> versioned "1.2.3" "https://this.is/link/to/image.png?q=abc"
-- | "https://this.is/link/to/image.png?q=abc&v=1.2.3"
-- | ```
versioned :: String -> String -> String
versioned version imageUrl =
  case indexOf (Pattern "?") imageUrl of
    Nothing -> imageUrl <> "?v=" <> version
    Just queryStart ->
      let
        base = take queryStart imageUrl
        query = drop (queryStart + 1) imageUrl
        params = split (Pattern "&") query
        filteredParams = filter (\p -> take 2 p /= "v=") params
        newParams = snoc filteredParams ("v=" <> version)
      in
        base <> "?" <> joinWith "&" newParams
