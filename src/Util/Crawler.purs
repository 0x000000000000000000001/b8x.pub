module Util.Crawler where

import Data.String.Regex as Regex
import Data.String.Regex.Flags (ignoreCase)
import Data.String.Regex.Unsafe (unsafeRegex)

crawlerRegex :: Regex.Regex
crawlerRegex = unsafeRegex "googlebot|bingbot|yandex|baiduspider|bytespider|rogerbot|embedly|quora link preview|showyoubot|outbrain|pinterest\\/0\\.|pinterestbot|facebookexternalhit|twitterbot|linkedinbot|whatsapp|telegrambot|slackbot|vkshare|w3c_validator|metatags|discordbot|skypeuripreview|applebot" ignoreCase

looksLikeCrawler :: String -> Boolean
looksLikeCrawler = Regex.test crawlerRegex
