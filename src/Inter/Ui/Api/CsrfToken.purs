module Inter.Ui.Api.CsrfToken (getCsrfToken) where

import Effect (Effect)

foreign import getCsrfToken :: Effect String
