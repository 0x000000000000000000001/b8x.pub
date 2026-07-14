module Util.Http.X where

-- This module exists solely to tell Spago that we use these packages.
-- They are actually used in Util/Http.js (FFI) where they are dynamically imported.
-- Imported nowhere, so that won't be in the output/, and won't disturb the browser (e.g. xhr2 not recognized)

import Affjax (AffjaxDriver)
import Affjax.Node as AffjaxNode
import Affjax.Web as AffjaxWeb

-- | Re-export the drivers so the imports are not considered unused
nodeDriver :: AffjaxDriver
nodeDriver = AffjaxNode.driver

webDriver :: AffjaxDriver  
webDriver = AffjaxWeb.driver
