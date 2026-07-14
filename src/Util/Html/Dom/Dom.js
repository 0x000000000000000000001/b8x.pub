import DOMPurify from 'dompurify';

// Removes <script> tags, event attributes (onload, onerror, etc.), and dangerous protocols.
// Note: designed for browser usage. For Node.js usage, see https://github.com/cure53/DOMPurify?tab=readme-ov-file#running-dompurify-on-the-server
export const _sanitize = (dirtyHtml) => DOMPurify.sanitize(dirtyHtml);

export const _setMetaContent = (name) => (content) => () => {
  var el = document.querySelector("meta[name='" + name + "']");
  if (!el) {
    el = document.querySelector("meta[property='" + name + "']");
  }
  if (el) {
    el.setAttribute("content", content);
  } else {
    var meta = document.createElement("meta");
    if (name.indexOf("og:") === 0) {
      meta.setAttribute("property", name);
    } else {
      meta.setAttribute("name", name);
    }
    meta.setAttribute("content", content);
    document.head.appendChild(meta);
  }
};

const _ensureMetaRobots = () => {
  let meta = document.querySelector('meta[name="robots"]');

  if (!meta) {
    meta = document.createElement('meta');
    meta.name = 'robots';
    document.head.appendChild(meta);
  }

  return meta;
}

export const _setMetaRobotsNoIndex = () => {
  const meta = _ensureMetaRobots();
  
  meta.content = 'noindex';
};

export const _setMetaRobotsDefault = () => {
  const meta = _ensureMetaRobots();

  meta.content = 'index, follow';
};

export const _setWindowLocationHref = (href) => () => {
  window.location.href = href;
};

export const _scrollTopAll = function(el) {
  return function() {
    if (el) {
      el.scrollTop = 0;
      var children = el.querySelectorAll('*');
      for (var i = 0; i < children.length; i++) {
        children[i].scrollTop = 0;
      }
    }
  };
};
