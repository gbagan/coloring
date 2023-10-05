module Main where

import Prelude

import Control.Monad.Reader (runReaderT)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import GraphParams.Model (init)
import GraphParams.Update (update)
import GraphParams.View (view)
import Pha.App (app)

main ∷ Effect Unit
main =
  app
    { init: { model: init, msg: Nothing }
    , update
    , view
    , selector: "#root"
    }
