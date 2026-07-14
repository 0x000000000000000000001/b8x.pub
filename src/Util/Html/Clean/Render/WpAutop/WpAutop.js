import wpautop from 'wpautop';

export const _wpAutop = br => text => {
  // 1. Remove Gutenberg block comments that confuse wpautop
  let result = text.replace(/<!--\s*\/?wp:[^>]*-->/gi, '');
  
  // 2. Remove empty paragraphs BEFORE wpautop (because wpautop corrupts existing <p></p> into stray </p> tags)
  let prev = null;
  while (result !== prev) {
    prev = result;
    result = result.replace(/<p[^>]*>(?:\s|&nbsp;|&#160;|\u200B|<br\s*\/?>)*<\/p>/gi, '');
  }

  // 3. Apply wpautop
  result = wpautop(result, br);
  
  // 4. Remove empty paragraphs AFTER wpautop (just in case wpautop produced any)
  prev = null;
  while (result !== prev) {
    prev = result;
    result = result.replace(/<p[^>]*>(?:\s|&nbsp;|&#160;|\u200B|<br\s*\/?>)*<\/p>/gi, '');
  }
  
  // 5. Cleanup excessive <br>
  result = result.replace(/(?:<br\s*\/?>\s*){2,}/gi, '<br />');
  
  return result;
};
