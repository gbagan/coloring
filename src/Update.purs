module GraphParams.Update where

import Relude

import Data.Argonaut.Core (stringify)
import Data.Argonaut.Decode (decodeJson)
import Data.Argonaut.Encode (encodeJson)
import Data.Argonaut.Parser (jsonParser)
import Data.Array (drop)
import GraphParams.Graph (Edge(..))
import GraphParams.Graph as Graph
import GraphParams.Layout (computeLayout)
import GraphParams.Model (Algorithm(..), Dialog(..), EditMode(..), Model, _graphs, _selectedGraph, _results
                        , selectedGraph, nbVertices, runColoring, stringToOrdering)
import GraphParams.Msg (Msg(..))
import GraphParams.Util (pointerDecoder, storageGet, storagePut)
import Pha.Update (Update)
import Web.Event.Event (stopPropagation)
import Web.PointerEvent.PointerEvent as PE
import Web.UIEvent.MouseEvent as ME

cleanResults ∷ Model → Model
cleanResults = _ { results = [], selectedResultIndex = 0, currentStep = 0 }

showColorNumber ∷ Model → Model
showColorNumber model =
  if model.currentStep /= nbVertices model then
    model
  else
    model # _results <<< ix model.selectedResultIndex %~ _ { showNumber = true }

update ∷ Msg → Update Model Msg Aff Unit
update (AddVertex ev) = do
  pos ← liftEffect $ pointerDecoder ev
  case pos of
    Nothing → pure unit
    Just p →
      modify_ \model →
        if model.editmode == VertexMode then
          cleanResults $ model # _selectedGraph %~ Graph.addVertex p
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
    Just p, MoveMode, Just i → model 
                                # _selectedGraph %~ Graph.moveVertex i p
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
    AddEMode, Just j → cleanResults $ (model # _selectedGraph %~ Graph.addEdge i j) { selectedVertex = Nothing }
    _, _ → model

update (DeleteVertex i ev) = do
  st ← get
  when (st.editmode == MoveMode)
    (liftEffect $ stopPropagation $ ME.toEvent ev)
  modify_ \model →
    if model.editmode == DeleteMode then
      model
        # _selectedGraph %~ Graph.removeVertex i
        # cleanResults
    else
      model

update (DeleteEdge (Edge u v)) =
  modify_ \model →
    if model.editmode == DeleteMode then
      model
        # _selectedGraph %~ Graph.removeEdge u v
        # cleanResults
    else
      model

update ClearGraph = modify_ \model → model 
                                        # _selectedGraph .~ { layout: [], edges: [] }
                                        # cleanResults
update GenBigGraph = modify_ \model → model 
                                        # _selectedGraph .~ Graph.bigGraph
                                        # cleanResults
update (SetEditMode mode) = modify_ _ { editmode = mode }

update AdjustGraph = modify_ \model → model # _selectedGraph %~ \graph →
                      graph { layout = computeLayout (length $ graph.layout) graph.edges }

update (SetGraph str) =
  modify_ \model →
    model { selectedGraphIdx =
      case str of
        "1" → 0
        "2" → 1
        "3" → 2
        "4" → 3
        "5" → 4
        "6" → 5
        "7" → 6
        "8" → 7
        _ → 0
    } # cleanResults 

update (SetAlgo name) =
  modify_ \model →
    model
      { currentStep = 0
      , selectedAlgorithm = 
          case name of
          "alpha" → Alphabetical
          "decdegree" → DecreasingDegree
          "indset" → IndependentSet
          "dsatur" → DSatur
          "custom" → CustomAlgorithm (0 .. (nbVertices model - 1))
          _ → Alphabetical
      }

update (CustomAlgoTextChange text) =
  modify_ \model →
    case stringToOrdering text of
      Nothing → model
      Just ord → model { selectedAlgorithm = CustomAlgorithm ord }
    
update (SetResultIndex idx) = modify_ _ {selectedResultIndex = idx, currentStep = 0}

update Save = do
  model ← get
  storagePut "coloring-graphs" $ stringify (encodeJson (drop 5 model.graphs))

update Load = do
  mtext <- storageGet "coloring-graphs"
  case mtext of
    Nothing → pure unit
    Just text →
      case jsonParser text of
        Left _ → pure unit
        Right json →
          case decodeJson json of
            Left _ → pure unit
            Right graphs →
              if length graphs /= 3
              then pure unit
              else _graphs %= \gs → take 5 gs <> graphs

update OpenImportDialog = modify_ \model → model { dialog = ImportDialog "" }

update (ChangeImportText text) = modify_ \model → model { dialog = ImportDialog text }

update ImportAndClose = modify_ \model →
  case model.dialog of
    ImportDialog text →
      case jsonParser text of
        Left _ → model { dialog = NoDialog }
        Right json →
          case decodeJson json of
            Left _ → model { dialog = NoDialog }
            Right graph → cleanResults $ (model # _selectedGraph .~ graph) { dialog = NoDialog }
    _ → model

update Export = modify_ \model → model { dialog = ExportDialog $ stringify (encodeJson (selectedGraph model))}

update CloseDialog = modify_ _ { dialog = NoDialog }

update Compute =
  modify_ \model@{ selectedAlgorithm, results } →
    let
      graph = selectedGraph model
    in
      case runColoring graph selectedAlgorithm of
        Nothing → model
        Just coloring → 
          let
            algorithm =
              { algorithm: selectedAlgorithm
              , coloring
              , number: 1 + fromMaybe (-1) (maximum (coloring # map _.color))
              , showNumber: false
              }
          in
            model { results = take 5 $ cons algorithm results }  

update PreviousStep =
  modify_ \model → model { currentStep = max 0 (model.currentStep-1) }

update NextStep =
  modify_ \model → showColorNumber $ model { currentStep = min (nbVertices model) (model.currentStep+1) }

update FinishColoring =
  modify_ \model → showColorNumber $ model { currentStep = nbVertices model }