<?php

$exports['_untag'] = function($isWAll, $wTags = null, $isBAll = null, $bTags = null, $replaceWithSpace = null, $str = null) use (&$exports) {
    if (\func_num_args() < 6) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$exports) {
            return $exports['_untag'](...\array_merge($__args, $more));
        };
    }
    
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
    
    return preg_replace_callback('/<\/?([a-zA-Z0-9:-]+)[^>]*>/', $callback, $str);
};

return $exports;
