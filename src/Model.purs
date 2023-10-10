module GraphParams.Model where

import Relude

import Data.Lens.AffineTraversal (AffineTraversal', affineTraversal)
import Data.Char (fromCharCode, toCharCode)
import Data.String.CodeUnits (fromCharArray, singleton, toCharArray)
import GraphParams.Coloring (Coloring, alphabeticalColoring, customColoring, decreasingDegreeColoring, indSetColoring, dsatur)
import GraphParams.Graph (Graph, toAdjGraph)

data EditMode = MoveMode | VertexMode | AddEMode | DeleteMode
derive instance Eq EditMode

type Position = { x ∷ Number, y ∷ Number}

data Algorithm 
  = Alphabetical
  | DecreasingDegree
  | IndependentSet
  | DSatur
  | CustomAlgorithm (Array Int)

data Dialog
  = NoDialog
  | ExportDialog String
  | ImportDialog String

labelToString ∷ Int → String
labelToString = singleton <<< fromMaybe 'A' <<< \n → fromCharCode (n + toCharCode 'A')

orderingToString ∷ Array Int → String
orderingToString = fromCharArray <<< catMaybes <<< map \n → fromCharCode (n + toCharCode 'A')

stringToOrdering ∷ String → Maybe (Array Int)
stringToOrdering text = Just $ text # toCharArray # map (\c → toCharCode c - toCharCode 'A')
-- todo

algoToString ∷ Algorithm → String
algoToString Alphabetical = "Alphabétique"
algoToString DecreasingDegree = "Degré décroissant"
algoToString IndependentSet = "Stables"
algoToString DSatur = "DSatur"
algoToString (CustomAlgorithm ord) = orderingToString ord

type Result = { algorithm ∷ Algorithm, coloring ∷ Coloring, number ∷ Int }

type Model =
  { selectedAlgorithm ∷ Algorithm
  , results ∷ Array Result
  , currentStep ∷ Int
  , selectedResultIndex ∷ Int
  , graphs ∷ Array Graph
  , selectedGraphIdx ∷ Int
  , editmode ∷ EditMode
  , selectedVertex ∷ Maybe Int
  , currentPosition ∷ Maybe Position
  , dialog ∷ Dialog
  }

init ∷ Model
init =
  { selectedAlgorithm: Alphabetical
  , results: []
  , currentStep: 0
  , selectedResultIndex: 0
  , graphs: replicate 4 {layout: [], edges: []}
  , selectedGraphIdx: 0
  , editmode: MoveMode
  , selectedVertex: Nothing
  , currentPosition: Nothing
  , dialog: NoDialog
  }

selectedGraph ∷ Model → Graph
selectedGraph {graphs, selectedGraphIdx} =
  fromMaybe {layout: [], edges: []} $ graphs !! selectedGraphIdx

_graphs ∷ Lens' Model (Array Graph)
_graphs = prop (Proxy ∷ _"graphs")


_selectedGraph ∷ AffineTraversal' Model Graph
_selectedGraph = affineTraversal set pre
  where
  set ∷ Model → Graph → Model
  set model@{graphs, selectedGraphIdx} b =
    model { graphs = fromMaybe graphs $ updateAt selectedGraphIdx b graphs }

  pre ∷ Model → Either Model Graph
  pre model = maybe (Left model) Right $ model.graphs !! model.selectedGraphIdx

nbVertices ∷ Model → Int
nbVertices model = length (selectedGraph model).layout

isAnOrdering ∷ Int → Array Int → Boolean
isAnOrdering _ [] = true
isAnOrdering n ord = sort ord == 0 .. (n - 1)

partialOrdering ∷ Model → Array Int
partialOrdering model@{currentStep, results, selectedResultIndex} =
  let
    graph = selectedGraph model
  in
  fromMaybe [] do
    {coloring} <- results !! selectedResultIndex
    pure $ take currentStep (map _.vertex coloring)

partialColoring ∷ Model → Array Int
partialColoring model@{currentStep, results, selectedResultIndex} =
  let
    graph = selectedGraph model
    emptyColoring = replicate (length graph.layout) (-1)
  in
  fromMaybe emptyColoring do
    {coloring} <- results !! selectedResultIndex
    let pcoloring = take currentStep coloring # map \{vertex, color} → vertex /\ color
    pure $ updateAtIndices pcoloring emptyColoring

runColoring ∷ Graph → Algorithm → Maybe Coloring
runColoring graph algo =
  let adjGraph = toAdjGraph graph in
  case algo of
    Alphabetical → Just $ alphabeticalColoring adjGraph
    DecreasingDegree → Just $ decreasingDegreeColoring adjGraph
    DSatur → Just $ dsatur adjGraph
    IndependentSet → Just $ indSetColoring adjGraph
    CustomAlgorithm ordering → 
      if isAnOrdering (length adjGraph) ordering then
        Just $ customColoring adjGraph ordering
      else
        Nothing