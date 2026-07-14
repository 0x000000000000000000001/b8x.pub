module Inter.Ui.Capability.ArticleCache.Trans where

import Proem

import Control.Monad.Trans.Class (class MonadTrans, lift)
import Data.Maybe (Maybe)
import Inter.Ui.Capability.ArticleCache.ArticleCache (AlreadyKnown, getArticleCache_, putArticleCache_)
import Inter.Ui.UiM (UiM(..))

getArticleCache :: ∀ t. MonadTrans t => String -> t UiM (Maybe AlreadyKnown)
getArticleCache slug = lift $ UiM $ getArticleCache_ slug

putArticleCache :: ∀ t. MonadTrans t => String -> AlreadyKnown -> t UiM Ɩ
putArticleCache slug known = lift $ UiM $ putArticleCache_ slug known
