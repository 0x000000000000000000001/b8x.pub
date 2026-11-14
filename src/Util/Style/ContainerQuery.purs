module Util.Style.ContainerQuery where

import Prelude
import CSS (CSS)
import Util.Style.Base (raw_)
import Halogen.HTML as HH

-- | Defines the container type (e.g. inline-size, normal, size)
containerType :: String -> CSS
containerType t = raw_ "container-type" t

-- | Shortcut for container-type: inline-size
containerTypeInlineSize :: CSS
containerTypeInlineSize = containerType "inline-size"

-- | Defines the container name to target it explicitly
containerName :: String -> CSS
containerName name = raw_ "container-name" name

-- | Generates a <style> tag containing a @container rule
-- | Example: containerQueryStyle "pocContainer" "max-width: 600px" ".child { color: blue; }"
containerQueryStyle :: forall w i. String -> String -> String -> HH.HTML w i
containerQueryStyle name condition rules =
  HH.style [] [ HH.text $ "@container " <> name <> " (" <> condition <> ") { " <> rules <> " }" ]
