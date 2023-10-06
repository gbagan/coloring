module GraphParams.Update where

import Relude

import Data.Argonaut.Core (stringify)
import Data.Argonaut.Decode (decodeJson)
import Data.Argonaut.Encode (encodeJson)
import Data.Argonaut.Parser (jsonParser)
import GraphParams.Graph (Edge(..))
import GraphParams.Graph as Graph
import GraphParams.Layout (computeLayout)
import GraphParams.Model (Algorithm(..), EditMode(..), Model, _graphs, currentGraph, nbVertices, runColoring)
import GraphParams.Msg (Msg(..))
import GraphParams.Util (pointerDecoder, storageGet, storagePut)
import Pha.Update (Update)
import Web.Event.Event (stopPropagation)
import Web.HTML.Event.EventTypes (offline)
import Web.PointerEvent.PointerEvent as PE
import Web.UIEvent.MouseEvent as ME

update ∷ Msg → Update Model Msg Aff Unit
update (AddVertex ev) = do
  pos ← liftEffect $ pointerDecoder ev
  case pos of
    Nothing → pure unit
    Just p →
      modify_ \model →
        if model.editmode == VertexMode then
          model # _graphs <<< ix model.currentGraphId %~ Graph.addVertex p
        else
          model

update (SelectVertex i ev) = do
  liftEffect $ stopPropagation $ PE.toEvent ev
  modify_ \model →
    if model.editmode `elem` [ AddEMode, MoveMode ] then
      model { selectedVertex = Just i }
    else
      model

update (GraphMove ev) = do
  pos ← liftEffect $ pointerDecoder (PE.toMouseEvent ev)
  modify_ \model → case pos, model.editmode, model.selectedVertex of
    Just p, MoveMode, Just i → model # _graphs <<< ix model.currentGraphId %~ Graph.moveVertex i p
    Just p, AddEMode, _ → model { currentPosition = Just p }
    _, _, _ → model

update DropOrLeave =
  modify_ \model →
    if model.editmode == AddEMode then
      model { selectedVertex = Nothing }
    else
      model

update (PointerUp i) = do
  modify_ \model → case model.editmode, model.selectedVertex of
    MoveMode, _ → model { selectedVertex = Nothing, currentPosition = Nothing }
    AddEMode, Just j → (model # _graphs <<< ix model.currentGraphId %~ Graph.addEdge i j) { selectedVertex = Nothing }
    _, _ → model

update (DeleteVertex i ev) = do
  st ← get
  when (st.editmode == MoveMode)
    (liftEffect $ stopPropagation $ ME.toEvent ev)
  modify_ \model →
    if model.editmode == DeleteMode then
      model # _graphs <<< ix model.currentGraphId %~ Graph.removeVertex i
    else
      model

update (DeleteEdge (Edge u v)) =
  modify_ \model →
    if model.editmode == DeleteMode then
      model # _graphs <<< ix model.currentGraphId %~ Graph.removeEdge u v
    else
      model

update ClearGraph = modify_ \model -> model # _graphs <<< ix model.currentGraphId .~ { layout: [], edges: [] }

update (SetEditMode mode) = modify_ \model → model { editmode = mode }

update AdjustGraph = modify_ \model → model # _graphs <<< ix model.currentGraphId %~ \graph ->
                      graph { layout = computeLayout (length $ graph.layout) graph.edges }

update (SetGraph str) =
  modify_ \model →
    model { currentGraphId = 
      case str of
        "1" -> 0
        "2" -> 1
        "3" -> 2
        "4" -> 3
        _ -> 0
    } 

update (SetAlgo name) =
  modify_ \model →
    model { selectedAlgorithm = 
      case name of
        "alpha" -> Alphabetical
        "decdegree" -> DecreasingDegree
        "dsatur" -> DSatur
        "custom" -> CustomAlgorithm (0 .. (nbVertices model - 1))
        _ -> Alphabetical
    } 

update Save = do
  model ← get
  storagePut "coloring-graphs" $ stringify (encodeJson model.graphs)

update Load = do
  mtext <- storageGet "coloring-graphs"
  case mtext of
    Nothing -> pure unit
    Just text ->
      case jsonParser text of
        Left _ → pure unit
        Right json →
          case decodeJson json of
            Left _ -> pure unit
            Right graphs -> modify_ _ { graphs = graphs }

update Compute =
  modify_ \model@{ selectedAlgorithm, results } →
    let
      graph = currentGraph model
      coloring = runColoring graph selectedAlgorithm
    in
    model { results = take 5 $ results `snoc` { algorithm: selectedAlgorithm, coloring, number: 1 + fromMaybe 0 (maximum (coloring # map _.color)) } }

update PreviousStep =
  modify_ \model -> model { currentStep = max 0 (model.currentStep-1) }

update NextStep =
  modify_ \model -> model { currentStep = min (nbVertices model) (model.currentStep+1) }

update FinishColoring =
  modify_ \model -> model { currentStep = nbVertices model }