module Util.Style.Classname where

import Proem hiding (bottom, top)
import Data.Array (foldl, last, (!!))
import Data.Array as Array
import Data.Char (toCharCode)
import Data.Int as Int
import Data.String (Pattern(..), split, stripPrefix, trim)
import Data.String.CodeUnits (toCharArray, fromCharArray)
import Halogen.HTML (ClassName(..), IProp)
import Halogen.HTML.Properties as HP
import Inter.Ui.Type.InstanceId (InstanceId(..))
import Util.Lexicon.Id (id_)
import Util.Type.String.String (caseToCamel)

fullModuleName :: String
fullModuleName = "Util.Style.Classname"

generateStaticClass :: String -> String
generateStaticClass fullModuleName' =
  let
    hash = hash9 $ fullModuleName'
    xs = split (Pattern ".") fullModuleName' # Array.filter (_ /= "Style")
    name = (last xs) ??⇒ ""
  in
    name <> "-" <> hash

refineClass :: String -> String -> String -> String
refineClass class' key value =
  let
    hash = hash9 $ class' <> "&" <> key <> "=" <> value
  in
    "--" <> caseToCamel key <> "-" <> hash

refineClass' :: String -> String -> String
refineClass' class' with = refineClass class' with with

inferInstanceClass :: String -> InstanceId -> String
inferInstanceClass class' (InstanceId id) = refineClass class' id_ id

inferAnimationId :: String -> String
inferAnimationId class' = refineClass' class' "animated"

class_ :: ∀ r i. String -> IProp (class :: String | r) i
class_ className = HP.class_ $ ClassName $ stripDotPrefixFromClassName className

classes :: ∀ r i. Array String -> IProp (class :: String | r) i
classes classNames =
  HP.classes
    $ ClassName
    <$>
      (classNames
          <#> (stripDotPrefixFromClassName ◁ trim)
          # (Array.filter (_ /= ""))
      )

stripDotPrefixFromClassName :: String -> String
stripDotPrefixFromClassName className = (stripPrefix (Pattern ".") className) ??⇒ className

hash9 :: ∀ a. Show a => a -> String
hash9 input =
  let
    str = show input

    -- Multiple hash values for better distribution
    hash1 = foldl (\acc char -> ((acc * 31) + toCharCode char) `Int.rem` 238328) 5381 (toCharArray str) -- 62^3
    hash2 = foldl (\acc char -> ((acc * 37) + toCharCode char) `Int.rem` 238328) 7919 (toCharArray str) -- 62^3
    hash3 = foldl (\acc char -> ((acc * 41) + toCharCode char) `Int.rem` 238328) 1009 (toCharArray str) -- 62^3

    -- Base62 characters for CSS-safe identifiers (using 'o' instead of '0')
    chars =
      [ 'o'
      , '1'
      , '2'
      , '3'
      , '4'
      , '5'
      , '6'
      , '7'
      , '8'
      , '9'
      , 'A'
      , 'B'
      , 'C'
      , 'D'
      , 'E'
      , 'F'
      , 'G'
      , 'H'
      , 'I'
      , 'J'
      , 'K'
      , 'L'
      , 'M'
      , 'N'
      , 'O'
      , 'P'
      , 'Q'
      , 'R'
      , 'S'
      , 'T'
      , 'U'
      , 'V'
      , 'W'
      , 'X'
      , 'Y'
      , 'Z'
      , 'a'
      , 'b'
      , 'c'
      , 'd'
      , 'e'
      , 'f'
      , 'g'
      , 'h'
      , 'i'
      , 'j'
      , 'k'
      , 'l'
      , 'm'
      , 'n'
      , 'p'
      , 'q'
      , 'r'
      , 's'
      , 't'
      , 'u'
      , 'v'
      , 'w'
      , 'x'
      , 'y'
      , 'z'
      ]
    letters =
      [ 'A'
      , 'B'
      , 'C'
      , 'D'
      , 'E'
      , 'F'
      , 'G'
      , 'H'
      , 'I'
      , 'J'
      , 'K'
      , 'L'
      , 'M'
      , 'N'
      , 'O'
      , 'P'
      , 'Q'
      , 'R'
      , 'S'
      , 'T'
      , 'U'
      , 'V'
      , 'W'
      , 'X'
      , 'Y'
      , 'Z'
      , 'a'
      , 'b'
      , 'c'
      , 'd'
      , 'e'
      , 'f'
      , 'g'
      , 'h'
      , 'i'
      , 'j'
      , 'k'
      , 'l'
      , 'm'
      , 'n'
      , 'o'
      , 'p'
      , 'q'
      , 'r'
      , 's'
      , 't'
      , 'u'
      , 'v'
      , 'w'
      , 'x'
      , 'y'
      , 'z'
      ]

    -- | Extract character from hash value
    getChar :: Int -> String
    getChar n =
      chars !! (n `Int.rem` 62)
        ?? (\c -> fromCharArray [ c ])
        ⇔ "o"

    -- | Extract letter for first char
    getLetter :: Int -> String
    getLetter n =
      letters !! (n `Int.rem` 52)
        ?? (\c -> fromCharArray [ c ])
        ⇔ "A"

  in
    -- Use different positions from each hash for better distribution
    getLetter hash1
      <> getChar (hash1 / 62)
      <> getChar (hash1 / 3844)
      <> getChar hash2
      <> getChar (hash2 / 62)
      <> getChar (hash2 / 3844)
      <> getChar hash3
      <> getChar (hash3 / 62)
      <> getChar (hash3 / 3844)

