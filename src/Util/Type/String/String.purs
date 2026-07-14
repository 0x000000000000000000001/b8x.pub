module Util.Type.String.String
  (Case(..)
  , Token(..)
  , caseTo
  , caseToCamel
  , caseToConstant
  , caseToHeader
  , caseToKebab
  , caseToPascal
  , caseToSnake
  , caseToTrain
  , collapseSpaces
  , collapseSpacesWithAtLeastOneNewline
  , frenchStopWords
  , isCamelCased
  , isConstantCased
  , isHeaderCased
  , isKebabCased
  , isPascalCased
  , isSnakeCased
  , isTrainCased
  , lowerCaseFirst
  , normalizeForFrenchTextSearch
  , normalizeForTextSearch
  , padLeft
  , padRight
  , removeAccents
  , removeFrenchStopWords
  , removeSpecialChars
  , replaceReturnsAndTabsWithSpaces
  , slugify
  , toRobustHtmlRegexPattern
  , tokenize
  , upperCaseFirst
  ) where

import Proem

import Data.Array (mapWithIndex, replicate)
import Data.Int (even)
import Data.String (Pattern(..), Replacement(..), joinWith, replaceAll, split, toLower, toUpper, trim)
import Data.String.CodeUnits (fromCharArray, length)
import Data.String.Regex (Regex, regex)
import Data.String.Regex (replace, split, test) as Regex
import Data.String.Regex.Flags (global, ignoreCase, noFlags, unicode)
import Data.String.Regex.Unsafe (unsafeRegex)
import Util.Html.Clean.Clean (clean)
import Util.Html.Encode.Encode (decodeHtmlEntities)
import Util.Type.String.ToString (class ToString)

-- | Pad a string on the left with a character to reach a minimum width
-- |
-- | Examples:
-- | ```purescript
-- | >>> padLeft 2 "0" "5"
-- | "05"
-- |
-- | >>> padLeft 4 " " "hi"
-- | "  hi"
-- |
-- | >>> padLeft 2 "0" "123"
-- | "123"
-- | ```
padLeft :: Int -> Char -> String -> String
padLeft width padChar str =
  let
    padding = width - length str
  in
    (padding <= 0
        ? str
        ↔ (fromCharArray (replicate padding padChar) <> str)
    )

-- | Pad a string on the right with a character to reach a minimum width
-- |
-- | Examples:
-- | ```purescript
-- | >>> padRight 4 " " "hi"
-- | "hi  "
-- |
-- | >>> padRight 5 "0" "123"
-- | "12300"
-- | ```
padRight :: Int -> Char -> String -> String
padRight width padChar str =
  let
    padding = width - length str
  in
    (padding <= 0
        ? str
        ↔ (str <> fromCharArray (replicate padding padChar))
    )

-- | Converts a string to a URL-friendly slug
-- |
-- | Examples:
-- | ```purescript
-- | >>> slugify "Christelle Evita"
-- | "christelle-evita"
-- |
-- | >>> slugify "Jean-Paul Dupont"
-- | "jean-paul-dupont"
-- |
-- | >>> slugify "  Marie  Louise  "
-- | "marie-louise"
-- | ```
slugify :: String -> String
slugify str =
  str
    # trim
    # toLower
    # removeAccents
    # replaceSpacesWithDashes
    # removeInvalidChars
    # removeConsecutiveDashes
    # trimDashes
  where
  replaceSpacesWithDashes :: String -> String
  replaceSpacesWithDashes = replaceAll (Pattern " ") (Replacement "-")

  removeInvalidChars :: String -> String
  removeInvalidChars s =
    regex "[^a-z0-9-]" global
      ?! (\re -> Regex.replace re "" s)
      ⇿ (κ s)

  removeConsecutiveDashes :: String -> String
  removeConsecutiveDashes s =
    regex "-+" global
      ?! (\re -> Regex.replace re "-" s)
      ⇿ (κ s)

  trimDashes :: String -> String
  trimDashes s =
    regex "^-+|-+$" global
      ?! (\re -> Regex.replace re "" s)
      ⇿ (κ s)

-- | Remove accents from characters
-- | Simple version - only handles common French accents
foreign import removeAccents :: String -> String

-- | Converts a string to a regex pattern string that is robust to common HTML editor alterations
-- | (encoded brackets, encoded accents, unbreakable spaces, injected tags...)
toRobustHtmlRegexPattern :: String -> String
toRobustHtmlRegexPattern str =
  split (Pattern "") str <#> escapeChar # joinWith ""
  where
  escapeChar :: String -> String
  escapeChar c = case c of
    "[" -> "(?:\\[|&#91;)"
    "]" -> "(?:\\]|&#93;)"
    "(" -> "(?:\\(|&#40;)"
    ")" -> "(?:\\)|&#41;)"
    " " -> "(?:\\s|&nbsp;|<[^>]*>)*"
    "'" -> "(?:'|&#39;|&apos;|’)"
    "à" -> "(?:à|&agrave;|&#224;)"
    "â" -> "(?:â|&acirc;|&#226;)"
    "ä" -> "(?:ä|&auml;|&#228;)"
    "é" -> "(?:é|&eacute;|&#233;)"
    "è" -> "(?:è|&egrave;|&#232;)"
    "ê" -> "(?:ê|&ecirc;|&#234;)"
    "ë" -> "(?:ë|&euml;|&#235;)"
    "î" -> "(?:î|&icirc;|&#238;)"
    "ï" -> "(?:ï|&iuml;|&#239;)"
    "ô" -> "(?:ô|&ocirc;|&#244;)"
    "ö" -> "(?:ö|&ouml;|&#246;)"
    "ù" -> "(?:ù|&ugrave;|&#249;)"
    "û" -> "(?:û|&ucirc;|&#251;)"
    "ü" -> "(?:ü|&uuml;|&#252;)"
    "ç" -> "(?:ç|&ccedil;|&#231;)"
    "À" -> "(?:À|&Agrave;|&#192;)"
    "Â" -> "(?:Â|&Acirc;|&#194;)"
    "Ä" -> "(?:Ä|&Auml;|&#196;)"
    "É" -> "(?:É|&Eacute;|&#201;)"
    "È" -> "(?:È|&Egrave;|&#200;)"
    "Ê" -> "(?:Ê|&Ecirc;|&#202;)"
    "Ë" -> "(?:Ë|&Euml;|&#203;)"
    "Î" -> "(?:Î|&Icirc;|&#206;)"
    "Ï" -> "(?:Ï|&Iuml;|&#207;)"
    "Ô" -> "(?:Ô|&Ocirc;|&#212;)"
    "Ö" -> "(?:Ö|&Ouml;|&#214;)"
    "Ù" -> "(?:Ù|&Ugrave;|&#217;)"
    "Û" -> "(?:Û|&Ucirc;|&#219;)"
    "Ü" -> "(?:Ü|&Uuml;|&#220;)"
    "Ç" -> "(?:Ç|&Ccedil;|&#199;)"
    "œ" -> "(?:œ|&oelig;|&#339;)"
    "Œ" -> "(?:Œ|&OElig;|&#338;)"
    "æ" -> "(?:æ|&aelig;|&#230;)"
    "Æ" -> "(?:Æ|&AElig;|&#198;)"
    "\\" -> "\\\\"
    "^" -> "\\^"
    "$" -> "\\$"
    "." -> "\\."
    "|" -> "\\|"
    "?" -> "\\?"
    "*" -> "\\*"
    "+" -> "\\+"
    "{" -> "\\{"
    "}" -> "\\}"
    _ -> c

removeSpecialChars :: String -> String
removeSpecialChars s =
  regex "[^\\p{L}\\p{N}\\s]" (global <> unicode)
    ?! (\re -> Regex.replace re " " s)
    ⇿ (κ s)

frenchStopWords :: Array String
frenchStopWords = split (Pattern "|") "a|afin|ai|aie|aient|aies|ainsi|ait|apres|as|attendu|au|aujourd|auquel|aura|aurai|auraient|aurais|aurait|auras|aurez|auriez|aurions|aurons|auront|aussi|autre|autres|aux|auxquelles|auxquels|avaient|avais|avait|avant|avec|avez|aviez|avions|avoir|avons|ayant|ayante|ayantes|ayants|ayez|ayons|c|ca|car|ce|ceci|cela|celle|celles|celui|cependant|certain|certaine|certaines|certains|ces|cet|cette|ceux|chez|ci|combien|comme|comment|compris|concernant|contre|d|dans|de|debout|dedans|dehors|dela|depuis|derriere|des|desormais|desquelles|desquels|dessous|dessus|devant|devers|devra|divers|diverse|diverses|doit|donc|dont|du|duquel|durant|elle|elles|en|entre|environ|es|est|et|etaient|etais|etait|etant|etante|etantes|etants|etat|etc|ete|etee|etees|etes|etiez|etions|etre|eu|eue|eues|euh|eumes|eurent|eus|eusse|eussent|eusses|eussiez|eussions|eut|eutes|eux|excepte|fumes|furent|fus|fusse|fussent|fusses|fussiez|fussions|fut|futes|helas|hormis|hors|hui|il|ils|j|je|jusqu|jusque|l|la|laquelle|le|lequel|les|lesquelles|lesquels|leur|leurs|lorsque|lui|m|ma|mais|malgre|me|meme|memes|merci|mes|mien|mienne|miennes|miens|moi|moins|mon|moyennant|n|ne|neanmoins|ni|non|nos|notre|notres|nous|on|ont|ou|outre|par|parmi|partant|pas|passe|pendant|plein|plus|plusieurs|pour|pourquoi|pres|proche|puisque|qu|quand|que|quel|quelle|quelles|quels|qui|quoi|quoique|revoici|revoila|s|sa|sans|sauf|se|sera|serai|seraient|serais|serait|seras|serez|seriez|serions|serons|seront|ses|si|sien|sienne|siennes|siens|sinon|soi|soient|sois|soit|sommes|son|sont|sous|soyez|soyons|suis|suite|sur|t|ta|te|tel|telle|telles|tels|tes|tien|tienne|tiennes|tiens|toi|ton|tous|tout|toute|toutes|tu|un|une|unes|uns|voici|voila|vos|votre|votres|vous|vu|y"

-- | Common French stop words (inspired from PostgreSQL pg_catalog.french)
-- | We pre-compile the regex to avoid recompiling it on every function call
-- | Note: no accents here.
frenchStopWordsRegex :: Regex
frenchStopWordsRegex =
  let
    pattern = "\\b(?:" <> joinWith "|" frenchStopWords <> ")\\b"
  in
    regex pattern (global <> unicode <> ignoreCase)
      ?! identity
      ⇿ (\_ -> unsafeRegex "^$" noFlags)

-- | Pre-compiled regex for multiple spaces
multiSpaceRegex :: Regex
multiSpaceRegex =
  regex "\\s+" global
    ?! identity
    ⇿ (\_ -> unsafeRegex "^$" noFlags)

-- | Pre-compiled regex for strict spaces
strictMultiSpaceRegex :: Regex
strictMultiSpaceRegex =
  regex " +" global
    ?! identity
    ⇿ (\_ -> unsafeRegex "^$" noFlags)

-- | Replace multiple whitespace characters with a single space.
-- | If strict is true, only replaces multiple space characters (" +").
-- | If strict is false, replaces any whitespace sequence ("\s+").
collapseSpaces :: Boolean -> String -> String
collapseSpaces strict = Regex.replace (strict ? strictMultiSpaceRegex ↔ multiSpaceRegex) " "

-- | Pre-compiled regex for a sequence of whitespaces containing at least one newline
spacesWithNewlineRegex :: Regex
spacesWithNewlineRegex =
  regex "\\s*\\n\\s*" global
    ?! identity
    ⇿ (\_ -> unsafeRegex "^$" noFlags)

-- | Pre-compiled regex for a sequence of spaces and newlines containing at least one newline (strict mode)
strictSpacesWithNewlineRegex :: Regex
strictSpacesWithNewlineRegex =
  regex "[ \\n]*\\n[ \\n]*" global
    ?! identity
    ⇿ (\_ -> unsafeRegex "^$" noFlags)

-- | Replace sequences of whitespaces containing at least one newline with the given string.
collapseSpacesWithAtLeastOneNewline :: Boolean -> String -> String -> String
collapseSpacesWithAtLeastOneNewline strict replacement = Regex.replace (strict ? strictSpacesWithNewlineRegex ↔ spacesWithNewlineRegex) replacement

-- | Remove common French stop words
removeFrenchStopWords :: String -> String
removeFrenchStopWords =
  Regex.replace frenchStopWordsRegex ""
    ▷ Regex.replace multiSpaceRegex " "
    ▷ trim

-- | Pre-compiled regex for returns and tabs
returnsAndTabsRegex :: Regex
returnsAndTabsRegex =
  regex "[\\r\\n\\t]+" global
    ?! identity
    ⇿ (\_ -> unsafeRegex "^$" noFlags)

-- | Replace returns and tabs with a single space.
replaceReturnsAndTabsWithSpaces :: String -> String
replaceReturnsAndTabsWithSpaces = Regex.replace returnsAndTabsRegex " "

-- | Normalize string for full text search (lowercase, no accents, spaces instead of punctuation...)
normalizeForTextSearch :: String -> String
normalizeForTextSearch =
  -- E.g. &eacute; -> é
  decodeHtmlEntities
    ▷ (clean true)
    ▷ removeAccents
    ▷ removeSpecialChars
    ▷ replaceReturnsAndTabsWithSpaces
    ▷ (collapseSpaces false)
    ▷ toLower
    ▷ trim

-- | Normalize string for full French text search (lowercase, no accents, no stop words, spaces instead of punctuation...)
normalizeForFrenchTextSearch :: String -> String
normalizeForFrenchTextSearch =
  -- E.g. &eacute; -> é
  decodeHtmlEntities
    ▷ (clean true)
    ▷ removeAccents
    ▷ removeSpecialChars
    ▷ removeFrenchStopWords -- The order is important
    ▷ replaceReturnsAndTabsWithSpaces
    ▷ (collapseSpaces false)
    ▷ toLower
    ▷ trim

-- | Uppercase the first character of a string
-- |
-- | Examples:
-- | ```purescript
-- | >>> upperCaseFirst "hello"
-- | "Hello"
-- | >>> upperCaseFirst ""
-- | ""
-- | ```
foreign import upperCaseFirst :: String -> String

-- | Uppercase the first character of a string
-- |
-- | Examples:
-- | ```purescript
-- | >>> typeStr_CaseFirst "Hello"
-- | "hello"
-- | >>> typeStr_CaseFirst ""
-- | ""
-- | ```
foreign import lowerCaseFirst :: String -> String

-- Case conversion

data Case = Pascal | Camel | Snake | Kebab | Constant | Train | Header

caseTo :: Case -> String -> String
caseTo case_ = case case_ of
  Pascal -> caseToPascal
  Camel -> caseToCamel
  Snake -> caseToSnake
  Kebab -> caseToKebab
  Constant -> caseToConstant
  Train -> caseToTrain
  Header -> caseToHeader

caseToPascal :: String -> String
caseToPascal "" = ""
caseToPascal s =
  regex "[-_ .\\s]+" global
    ?! (\re -> Regex.split re s <#> upperCaseFirst # joinWith "")
    ⇿ (κ s)

caseToCamel :: String -> String
caseToCamel = lowerCaseFirst ◁ caseToPascal

caseToSnake :: String -> String
caseToSnake "" = ""
caseToSnake s =
  let
    pascal = caseToPascal s
    underscored =
      regex "([A-Z])" global
        ?! (\re -> Regex.replace re "_$1" pascal)
        ⇿ (κ pascal)
    lowercased = toLower underscored
  in
    regex "^_+" noFlags
      ?! (\re -> Regex.replace re "" lowercased)
      ⇿ (κ lowercased)

caseToKebab :: String -> String
caseToKebab = caseToSnake ▷ replaceAll (Pattern "_") (Replacement "-")

caseToConstant :: String -> String
caseToConstant = caseToSnake ▷ toUpper

caseToTrain :: String -> String
caseToTrain = caseToKebab ▷ toUpper

caseToHeader :: String -> String
caseToHeader s =
  let
    kebab = caseToKebab s
  in
    regex "-" global
      ?! (\re -> Regex.split re kebab <#> upperCaseFirst # joinWith "-")
      ⇿ (κ kebab)

-- Case detection

isCamelCased :: String -> Boolean
isCamelCased s =
  regex "^[a-z0-9]+([A-Z0-9][a-z0-9]*)*$" noFlags
    ?! (\re -> Regex.test re s)
    ⇿ (κ false)

isPascalCased :: String -> Boolean
isPascalCased s =
  regex "^[A-Z][a-zA-Z0-9]*$" noFlags
    ?! (\re -> Regex.test re s)
    ⇿ (κ false)

isSnakeCased :: String -> Boolean
isSnakeCased s =
  regex "^[a-z0-9_]+$" noFlags
    ?! (\re -> Regex.test re s)
    ⇿ (κ false)

isKebabCased :: String -> Boolean
isKebabCased s =
  regex "^[a-z0-9-]+$" noFlags
    ?! (\re -> Regex.test re s)
    ⇿ (κ false)

isConstantCased :: String -> Boolean
isConstantCased s =
  regex "^[A-Z0-9_]+$" noFlags
    ?! (\re -> Regex.test re s)
    ⇿ (κ false)

isTrainCased :: String -> Boolean
isTrainCased s =
  regex "^[A-Z0-9-]+$" noFlags
    ?! (\re -> Regex.test re s)
    ⇿ (κ false)

isHeaderCased :: String -> Boolean
isHeaderCased s =
  regex "^[A-Z][a-zA-Z0-9]*(-[A-Z][a-zA-Z0-9]*)*$" noFlags
    ?! (\re -> Regex.test re s)
    ⇿ (κ false)

-- | Pre-compiled regex for tokenization
tokenizeRegex :: Regex
tokenizeRegex =
  regex "([\\p{L}\\p{N}]+)" (global <> unicode)
    ?! identity
    ⇿ (\_ -> unsafeRegex "^$" noFlags)

data Token
  = Separator String
  | Word String

derive instance Eq Token

instance ToString Token where
  toString (Separator s) = s
  toString (Word s) = s

-- | Split a string into tokens of letters/numbers (Word) vs the rest (Separator)
tokenize :: String -> Array Token
tokenize str =
  Regex.split tokenizeRegex str
    # mapWithIndex \i t ->
        if even i then Separator t else Word t
