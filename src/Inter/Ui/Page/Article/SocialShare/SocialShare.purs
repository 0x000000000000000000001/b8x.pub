module Inter.Ui.Page.Article.SocialShare.SocialShare
  (socialShare
  ) where

import Proem hiding (div)

import Halogen.HTML (HTML, a)
import Halogen.HTML.Properties (href, target, title)
import Inter.Ui.Page.Article.SocialShare.Style.Style as Style
import Util.Html.Clean.Render.Render (SanitizedHtmlString(..), render)
import Core.Mod.Article.Slug.Slug (Slug)
import Util.Type.String.ToString (toString)

socialShare :: ∀ w i. Slug -> HTML w i
socialShare slug =
  let
    articleUrl = "https://magazine.books.fr/article/" <> toString slug
  in
    Style.socialShare_
      [ Style.socialShareInner_
          [ a [ href ("https://www.facebook.com/sharer/sharer.php?u=" <> articleUrl)
              , target "_blank"
              , title "Partager sur Facebook"
              ] [ render (SanitizedHtmlString facebookSvg) ]
          , a [ href ("https://twitter.com/intent/tweet?url=" <> articleUrl)
              , target "_blank"
              , title "Partager sur X"
              ] [ render (SanitizedHtmlString xSvg) ]
          , a [ href ("https://www.linkedin.com/sharing/share-offsite/?url=" <> articleUrl)
              , target "_blank"
              , title "Partager sur LinkedIn"
              ] [ render (SanitizedHtmlString linkedinSvg) ]
          ]
      ]

facebookSvg :: String
facebookSvg =
  """<svg viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg"><path d="M22 12c0-5.52-4.48-10-10-10S2 6.48 2 12c0 4.84 3.44 8.87 8 9.8V15H8v-3h2V9.5C10 7.57 11.57 6 13.5 6H16v3h-2c-.55 0-1 .45-1 1v2h3v3h-3v6.95c5.05-.5 9-4.76 9-9.95z"/></svg>"""

xSvg :: String
xSvg =
  """<svg viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>"""

linkedinSvg :: String
linkedinSvg =
  """<svg viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg"><path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/></svg>"""
