module GraphParams.Main where

import Relude hiding (view)

import GraphParams.Model (init)
import GraphParams.Update (update)
import GraphParams.Msg (Msg(..))
import GraphParams.View (view)
import Pha.App (app)

main ∷ Effect Unit
main =
  app
    { init: { model: init, msg: Just Load }
    , update
    , view
    , selector: "#root"
    }
