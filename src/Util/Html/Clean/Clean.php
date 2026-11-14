<?php

$exports['_untag'] = function($isWAll, $wTags, $isBAll, $bTags, $replaceWithSpace, $str) {
    // We use a native preg_replace_callback which avoids creating PureScript Thunks 
    // and function invocations on every single HTML tag, boosting performance massively.
    $callback = function($matches) use ($isWAll, $wTags, $isBAll, $bTags, $replaceWithSpace) {
        $tagName = strtolower($matches[1]);
        
        $isWhitelisted = $isWAll || in_array($tagName, $wTags);
        $isBlacklistedInWhitelist = $isBAll || in_array($tagName, $bTags);
        
        if ($isWhitelisted && !$isBlacklistedInWhitelist) {
            return $matches[0];
        }
        return $replaceWithSpace ? " " : "";
    };
    
    $stripped = preg_replace_callback('/<\/?([a-zA-Z0-9:-]+)[^>]*>/', $callback, $str);
    if ($stripped === null) {
        throw new \RuntimeException('Failed to strip HTML tags');
    }
    return $stripped;
};

return $exports;
