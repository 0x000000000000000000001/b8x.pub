import DOMPurify from 'dompurify';

const blacklistedAttributes = ['id', 'class', 'data-cke-saved-href', 'data-mce-fragment'];

const blacklistedStyles = ['font-size', 'font-family', 'background', 'background-color', 'word-spacing'];
const blacklistedStylesRegex = new RegExp(`(?:${blacklistedStyles.join('|')})\\s*:[^;]+;?`, 'gi');

const blacklistedStylesPerNodeAncestorNameIncludingItself = {
    'A': ['color', 'text-decoration-color']
};

const blacklistedStylesRegexPerNodeAncestorNameIncludingItself = {};
for (const [nodeName, styles] of Object.entries(blacklistedStylesPerNodeAncestorNameIncludingItself)) {
    blacklistedStylesRegexPerNodeAncestorNameIncludingItself[nodeName] = new RegExp(`(^|;)\\s*(?:${styles.join('|')})\\s*:[^;]+;?`, 'gi');
}

const allowedTags = ['iframe'];
const allowedAttributes = ['allow', 'allowfullscreen', 'frameborder', 'scrolling'];

const uponSanitizeAttributeHook = function (node, data) {
    if (data.attrName === 'style') {
        let cleanStyle = data.attrValue.replace(blacklistedStylesRegex, '').trim();
        for (const [nodeName, nodeRegex] of Object.entries(blacklistedStylesRegexPerNodeAncestorNameIncludingItself)) {
            if (node.closest(nodeName)) {
                cleanStyle = cleanStyle.replace(nodeRegex, '$1').trim();
            }
        }
        if (cleanStyle === '') {
            data.keepAttr = false;
        } else {
            data.attrValue = cleanStyle;
        }
    }
};

const targetBlankHook = function (node) {
    if (node.nodeName && node.nodeName === 'A') {
        node.setAttribute('target', '_blank');
        // noopener prevents the new tab from maliciously controlling the original window via window.opener
        // noreferrer prevents leaking the referer URL for privacy
        node.setAttribute('rel', 'noopener noreferrer');
    }
};

const _sanitizeWithHooks = (html, config, extraHooks = []) => {
    DOMPurify.addHook('uponSanitizeAttribute', uponSanitizeAttributeHook);
    extraHooks.forEach(hook => DOMPurify.addHook(hook.name, hook.fn));
    const res = DOMPurify.sanitize(html, config);
    DOMPurify.removeHook('uponSanitizeAttribute');
    extraHooks.forEach(hook => DOMPurify.removeHook(hook.name));
    return res;
};

export const _sanitizeHtml = (html) => {
    return _sanitizeWithHooks(html, {
        FORBID_ATTR: blacklistedAttributes,
        ADD_TAGS: allowedTags,
        ADD_ATTR: allowedAttributes
    }, [
        { name: 'afterSanitizeAttributes', fn: targetBlankHook }
    ]);
};

