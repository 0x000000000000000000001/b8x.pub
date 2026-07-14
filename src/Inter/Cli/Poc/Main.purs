module Inter.Cli.Poc.Main (main) where

import Proem
import Data.Maybe (Maybe(..))

import Infra.Client.Sendy as Sendy
import Inter.Cli.Poc.PocM (acquire, complete, runPocM)
import Effect.Class.Console (log)
import Effect (Effect)
import Effect.Aff (bracket)
import Inter.Cli.Util.Aff (runCliAff)

main :: Effect Ɩ
main = runCliAff $ bracket acquire complete \ctx -> runPocM ctx do
  log "Envoi d'une campagne de test via Sendy..."

  Sendy.createCampaign
    { title: "POC Campaign Title"
    , subject: "POC Campaign Subject"
    , htmlText: "<html><body><h1>Hello from POC</h1><p>Test de l'API Sendy !</p></body></html>"
    , sendRightaway: false
    , scheduledFor: Nothing
    }

  log "Appel API Sendy terminé avec succès."
