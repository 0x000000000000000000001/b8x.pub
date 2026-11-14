// Google Analytics 4 page view tracking for the single-page application.
//
// The gtag library is loaded and configured in public/index.html with
// `send_page_view: false`, so every page view is reported from here. Page
// identity is the pathname: navigating within the same page (opening the
// menu, consuming a magic link token, etc.) only changes the query string and
// must not be reported.
//
// Each pending page view is debounced so the page metadata has time to settle,
// which lets real titles (loaded after the initial placeholder) be used when
// they are available. A page view is also flushed immediately when the page
// changes again, so fast consecutive navigations are not lost.

const PAGE_VIEW_DEBOUNCE_MS = 500;

let lastSentPathname = null;
let pendingPageView = null;
let pendingTimer = null;

const sendPageView = (pathname, title) => {
  if (pathname === lastSentPathname) {
    return;
  }

  lastSentPathname = pathname;

  if (typeof window === 'undefined' || typeof window.gtag !== 'function') {
    return;
  }

  window.gtag('event', 'page_view', {
    page_location: window.location.origin + pathname,
    page_path: pathname,
    page_title: title,
  });
};

const flushPendingPageView = () => {
  clearTimeout(pendingTimer);
  pendingTimer = null;

  if (pendingPageView === null) {
    return;
  }

  const { pathname, title } = pendingPageView;
  pendingPageView = null;

  sendPageView(pathname, title);
};

export const _trackPageView = () => {
  if (typeof window === 'undefined') {
    return;
  }

  const pathname = window.location.pathname;

  if (pendingPageView !== null && pendingPageView.pathname !== pathname) {
    flushPendingPageView();
  }

  pendingPageView = { pathname, title: document.title };

  clearTimeout(pendingTimer);
  pendingTimer = setTimeout(flushPendingPageView, PAGE_VIEW_DEBOUNCE_MS);
};
