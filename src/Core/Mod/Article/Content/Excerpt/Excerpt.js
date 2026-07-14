export const _truncateInnerTextThenHealOuterHtml = limit => suffix => htmlStr => {
    if (limit < 0) return htmlStr;
    if (!htmlStr || htmlStr.trim() === '') return htmlStr;
    
    // In browser or JSDOM environment, DOMParser is available globally
    const parser = new DOMParser();
    const doc = parser.parseFromString(htmlStr, 'text/html');
    
    let remaining = limit;
    let truncated = false;
    
    const walk = node => {
        if (truncated) {
            node.parentNode.removeChild(node);
            return;
        }
        
        if (node.nodeType === 3) { // Text node
            const text = node.nodeValue;
            const len = text.length;
            if (len > remaining) {
                const spaceIdx = text.indexOf(' ', remaining);
                if (spaceIdx !== -1) {
                    node.nodeValue = text.substring(0, spaceIdx);
                }
                remaining = 0;
                truncated = true;
            } else {
                remaining -= len;
            }
        } else {
            const children = Array.from(node.childNodes);
            children.forEach(walk);
        }
    };
    
    Array.from(doc.body.childNodes).forEach(walk);
    return doc.body.innerHTML + (truncated ? suffix : '');
};
