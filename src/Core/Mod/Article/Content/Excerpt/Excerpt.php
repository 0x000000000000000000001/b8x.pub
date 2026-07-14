<?php

$exports['_truncateInnerTextThenHealOuterHtml'] = function($limit, $suffix = null, $htmlStr = null) use (&$exports) {
    if (\func_num_args() < 3) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$exports) {
            return $exports['_truncateInnerTextThenHealOuterHtml'](...\array_merge($__args, $more));
        };
    }

    if ($limit < 0) return $htmlStr;
    if (trim($htmlStr) === '') return $htmlStr;

    $dom = new \DOMDocument();
    
    // Disable libxml errors to prevent HTML parsing warnings
    $internalErrors = libxml_use_internal_errors(true);
    
    // LIBXML_HTML_NOIMPLIED | LIBXML_HTML_NODEFDTD prevents DOMDocument from adding <html><body>...
    $dom->loadHTML('<?xml encoding="utf-8" ?>' . $htmlStr, LIBXML_HTML_NOIMPLIED | LIBXML_HTML_NODEFDTD | LIBXML_NOERROR | LIBXML_NOWARNING);
    libxml_use_internal_errors($internalErrors);

    $remaining = $limit;
    $truncated = false;

    $walk = function($node) use (&$walk, &$remaining, &$truncated) {
        if ($truncated) {
            $node->parentNode->removeChild($node);
            return;
        }

        if ($node->nodeType === XML_TEXT_NODE) {
            $text = $node->nodeValue;
            $len = mb_strlen($text);
            if ($len > $remaining) {
                // Find next space
                $spaceIdx = mb_strpos($text, ' ', $remaining);
                if ($spaceIdx !== false) {
                    $node->nodeValue = mb_substr($text, 0, $spaceIdx);
                }
                $remaining = 0;
                $truncated = true;
            } else {
                $remaining -= $len;
            }
        } else {
            // Must collect children in array first because removing elements affects the nodelist
            $children = [];
            foreach ($node->childNodes as $child) {
                $children[] = $child;
            }
            foreach ($children as $child) {
                $walk($child);
            }
        }
    };

    foreach ($dom->childNodes as $node) {
        $walk($node);
    }

    $out = '';
    foreach ($dom->childNodes as $node) {
        $out .= $dom->saveHTML($node);
    }

    $out = str_replace('<?xml encoding="utf-8" ?>', '', $out);
    return $out . ($truncated ? $suffix : '');
};

return $exports;
