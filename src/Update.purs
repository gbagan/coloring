module GraphParams.Update where

import Prelude

import Data.Array ((..), elem, length, take, snoc)
import Data.Foldable (maximum)
import Data.Maybe (Maybe(..), fromMaybe)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import GraphParams.Graph (Edge(..))
import GraphParams.Graph as Graph
import GraphParams.Layout (computeLayout)
import GraphParams.Model (Algorithm(..), EditMode(..), Model, nbVertices, runColoring)
import GraphParams.Msg (Msg(..))
import Pha.Update (Update, get, modify_)
import Util (pointerDecoder)
import Web.Event.Event (stopPropagation)
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
          model { graph = Graph.addVertex p model.graph }
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
    Just p, MoveMode, Just i → model { graph = Graph.moveVertex i p model.graph }
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
    AddEMode, Just j → model { graph = Graph.addEdge i j model.graph, selectedVertex = Nothing }
    _, _ → model

update (DeleteVertex i ev) = do
  st ← get
  when (st.editmode == MoveMode)
    (liftEffect $ stopPropagation $ ME.toEvent ev)
  modify_ \model →
    if model.editmode == DeleteMode then
      model { graph = Graph.removeVertex i model.graph }
    else
      model

update (DeleteEdge (Edge u v)) =
  modify_ \model →
    if model.editmode == DeleteMode then
      model { graph = Graph.removeEdge u v model.graph }
    else
      model

update ClearGraph = modify_ _ { graph = { layout: [], edges: [] } }

update (SetEditMode mode) = modify_ \model → model { editmode = mode }

update AdjustGraph = modify_ \model@{ graph } → model { graph = graph { layout = computeLayout (length $ graph.layout) graph.edges } }

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


update Compute =
  modify_ \model@{ graph, selectedAlgorithm, results } →
    let coloring = runColoring graph selectedAlgorithm in
    model { results = take 5 $ results `snoc` { algorithm: selectedAlgorithm, coloring, number: 1 + fromMaybe 0 (maximum (coloring # map _.color)) } }

update PreviousStep =
  modify_ \model -> model { currentStep = max 0 (model.currentStep-1) }

update NextStep =
  modify_ \model -> model { currentStep = min (nbVertices model) (model.currentStep+1) }

update FinishColoring =
  modify_ \model -> model { currentStep = nbVertices model }