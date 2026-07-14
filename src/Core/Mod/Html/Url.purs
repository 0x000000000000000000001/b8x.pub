module Core.Mod.Html.Url where

import Proem

import Config.PublicConfig (publicConfig)
import Core.Mod.Html.Html (NonEmptyHtml(..), unsafeFromString)
import Data.String as String
import Data.String.Pattern (Pattern(..), Replacement(..))
import Data.String.Regex (replace) as Regex
import Data.String.Regex.Flags (global, ignoreCase)
import Data.String.Regex.Unsafe (unsafeRegex)

absolutizeOurObjectStorageUrls :: NonEmptyHtml -> NonEmptyHtml
absolutizeOurObjectStorageUrls (NonEmptyHtml html) =
  let
    urlBase = publicConfig.objectStorage.urlBase
    publicPath = publicConfig.objectStorage.publicPathBase

    rawPrefix = urlBase <> publicPath <> "/"
    -- Replace // with / except after : (for https://)
    cleanPrefix = Regex.replace (unsafeRegex "([^:])\\/\\/+" (global <> ignoreCase)) "$1/" rawPrefix

    pb = String.drop 1 publicPath
    rxStr = "(src|href)=[\"'](?:\\/)?" <> pb <> "\\/"
    rx = unsafeRegex rxStr (global <> ignoreCase)
    replacement = "$1=\"" <> cleanPrefix
  in
    unsafeFromString $ Regex.replace rx replacement html

relativizeCleanOurUrls :: NonEmptyHtml -> NonEmptyHtml
relativizeCleanOurUrls (NonEmptyHtml html) =
  let
    escapeDot = String.replaceAll (Pattern ".") (Replacement "\\.")
    legacyHost = escapeDot publicConfig.ui.legacyHost
    baseHost = escapeDot $ publicConfig.ui.dns.level2.a <> "." <> publicConfig.ui.dns.level1

    -- Allow matching any subdomain ending with legacyHost or baseHost
    hostsPattern = "(?:[a-zA-Z0-9-]+\\.)*(?:" <> legacyHost <> "|" <> baseHost <> ")"

    -- Pass 0: Prefix naked domains with https://
    -- Matches src="domain.com/..." where the first segment contains a dot and no colon.
    rx0Str = "(src|href)=([\"'])([^:/?#\"']+\\.[^:/?#\"']+)"
    rx0 = unsafeRegex rx0Str (global <> ignoreCase)
    html0 = Regex.replace rx0 "$1=$2https://$3" html

    -- Pass 1: Replace https://host/path with /path
    rx1Str = "(src|href)=[\"']https?:\\/\\/" <> hostsPattern <> "(\\/[^\"']*)[\"']"
    rx1 = unsafeRegex rx1Str (global <> ignoreCase)
    html1 = Regex.replace rx1 "$1=\"$2\"" html0

    -- Pass 2: Replace https://host with / (when path is empty)
    rx2Str = "(src|href)=[\"']https?:\\/\\/" <> hostsPattern <> "[\"']"
    rx2 = unsafeRegex rx2Str (global <> ignoreCase)
    html2 = Regex.replace rx2 "$1=\"/\"" html1

    -- Pass 3: Remove trailing slashes on all relative paths (except root /)
    -- e.g. /article/ becomes /article
    rx3Str = "(src|href)=[\"'](\\/[^\"']*[^\\/\"'])(\\/+)[\"']"
    rx3 = unsafeRegex rx3Str (global <> ignoreCase)
    html3 = Regex.replace rx3 "$1=\"$2\"" html2
  in
    unsafeFromString html3

