import { isNode } from '../Util.Runtime/index.js'

let he;
if (isNode) he = (await import(/* @vite-ignore */ 'he')).default;

const textArea = isNode ? null : document.createElement('textarea');

export const _decodeHtmlEntities = (str) => {
    // Browser
    if (textArea) {
        textArea.innerHTML = str;
        return textArea.value;
    }

    // Node
    try {
        return he.decode(str);
    } catch (e) {
        // console.error(e);
        return str;
    }
};

export const _encodeHtmlEntities = (str) => {
    // Browser
    if (textArea) {
        textArea.textContent = str;
        return textArea.innerHTML;
    }
    
    // Node
    try {
        return he.encode(str);
    } catch (e) {
        // console.error(e);
        return str;
    }
};