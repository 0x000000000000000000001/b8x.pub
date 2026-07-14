module Inter.Ui.Page.Home.FrontPage.Column.Article.Util where

import Proem hiding (div, top)

import CSS (StyleM)
import Util.Style.Effect as Effect


loadingOpt :: Effect.LoadingOpt
loadingOpt =
  Effect.defaultLoadingOpt
    { opacity = 0.08
    , shimmerOpacity = 0.2
    }

loading :: StyleM Ɩ
loading = Effect.loading loadingOpt
