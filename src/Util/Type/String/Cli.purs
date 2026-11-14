module Util.Type.String.Cli where

import Proem

import Data.String (trim, toLower)

-- | Checks if a string means "yes" (accepts: yes, y, o, oui, true, 1)
isYes :: String -> Boolean -> Boolean
isYes s emptyIncluded =
  let
    s' = toLower (trim s)
  in
    s' == "yes" || s' == "y" || s' == "o" || s' == "oui" || s' == "true" || s' == "1" || (emptyIncluded && s' == "")

-- | Checks if a string means "no" (accepts: no, n, non, false, 0, "")
isNo :: String -> Boolean -> Boolean
isNo s emptyIncluded =
  let
    s' = toLower (trim s)
  in
    s' == "no" || s' == "n" || s' == "non" || s' == "false" || s' == "0" || (emptyIncluded && s' == "")
