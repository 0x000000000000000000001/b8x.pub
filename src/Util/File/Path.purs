module Util.File.Path where

import Proem
import Util.File.Image.Common (versioned)

-- | Ends with '/'
foreign import _rootDirAbsolutePath :: String

outputDirRelativePath :: String
outputDirRelativePath = "output/"

outputDirAbsolutePath :: String
outputDirAbsolutePath = _rootDirAbsolutePath <> outputDirRelativePath

srcDirRelativePath :: String
srcDirRelativePath = "src/"

srcDirAbsolutePath :: String
srcDirAbsolutePath = _rootDirAbsolutePath <> srcDirRelativePath

metaDirRelativePath :: String
metaDirRelativePath = "_/"

metaDirAbsolutePath :: String
metaDirAbsolutePath = srcDirAbsolutePath <> metaDirRelativePath

publicDirRelativePath :: String
publicDirRelativePath = "public/"

publicDirAbsolutePath :: String
publicDirAbsolutePath = _rootDirAbsolutePath <> publicDirRelativePath

assetDirRelativePath :: String
assetDirRelativePath = "asset/"

assetDirAbsolutePath :: String
assetDirAbsolutePath = publicDirAbsolutePath <> assetDirRelativePath

imageDirRelativePath :: String
imageDirRelativePath = assetDirRelativePath <> "image/"

imageDirAbsolutePath :: String
imageDirAbsolutePath = publicDirAbsolutePath <> imageDirRelativePath

selfHostedAssetUrl :: String -> String
selfHostedAssetUrl assetRelativePath = "/" <> assetDirRelativePath <> assetRelativePath

selfHostedImageUrl :: String -> String
selfHostedImageUrl imageRelativePath = "/" <> imageDirRelativePath <> imageRelativePath

selfHostedVersionedImageUrl :: String -> String -> String
selfHostedVersionedImageUrl version imageRelativePath = selfHostedImageUrl imageRelativePath # versioned version
