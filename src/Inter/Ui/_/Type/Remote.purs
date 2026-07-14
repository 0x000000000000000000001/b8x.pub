module Inter.Ui.Type.Remote where

import Network.RemoteData (RemoteData)

type Remote a = RemoteData String a
