module GraphParams.Model where

import Relude

import Data.Char (fromCharCode, toCharCode)
import Data.String.CodeUnits (fromCharArray, singleton, toCharArray)
import GraphParams.Coloring (Coloring, alphabeticalColoring, customColoring, decreasingDegreeColoring, dsatur)
import GraphParams.Graph (Graph, toAdjGraph)

data EditMode = MoveMode | VertexMode | AddEMode | DeleteMode
derive instance Eq EditMode

type Position = { x ∷ Number, y ∷ Number}

data Algorithm 
  = Alphabetical
  | DecreasingDegree
  | DSatur
  | CustomAlgorithm (Array Int)

data Dialog
  = NoDialog
  | ExportDialog String
  | ImportDialog String

labelToString :: Int -> String
labelToString = singleton <<< fromMaybe 'A' <<< \n -> fromCharCode (n + toCharCode 'A')

orderingToString :: Array Int -> String
orderingToString = fromCharArray <<< catMaybes <<< map \n -> fromCharCode (n + toCharCode 'A')

stringToOrdering :: String -> Maybe (Array Int)
stringToOrdering text = Just $ text # toCharArray # map (\c -> toCharCode c - toCharCode 'A')
-- todo

algoToString :: Algorithm -> String
algoToString Alphabetical = "alphabétique"
algoToString DecreasingDegree = "degré décroissant"
algoToString DSatur = "DSatur"
algoToString (CustomAlgorithm ord) = orderingToString ord

type Result = { algorithm ∷ Algorithm, coloring ∷ Coloring, number ∷ Int }

type Model =
  { selectedAlgorithm ∷ Algorithm
  , results ∷ Array Result
  , currentStep ∷ Int
  , currentResultIndex ∷ Int
  , graphs ∷ Array Graph
  , currentGraphId ∷ Int
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
  , currentResultIndex: 0
  , graphs: replicate 4 {layout: [], edges: []}
  , currentGraphId: 0
  , editmode: VertexMode
  , selectedVertex: Nothing
  , currentPosition: Nothing
  , dialog: NoDialog
  }

currentGraph ∷ Model -> Graph
currentGraph {graphs, currentGraphId} =
  fromMaybe {layout: [], edges: []} $ graphs !! currentGraphId

_graphs :: Lens' Model (Array Graph)
_graphs = prop (Proxy :: _"graphs")

nbVertices ∷ Model -> Int
nbVertices model = length (currentGraph model).layout

partialColoring ∷ Model -> Array Int
partialColoring model@{currentStep, results, currentResultIndex} =
  let
    graph = currentGraph model
    emptyColoring = replicate (length graph.layout) (-1)
  in
  fromMaybe emptyColoring do
    {coloring} <- results !! currentResultIndex
    let pcoloring = take currentStep coloring # map \{vertex, color} -> vertex /\ color
    pure $ updateAtIndices pcoloring emptyColoring

runColoring ∷ Graph -> Algorithm -> Coloring
runColoring graph algo =
  let adjGraph = toAdjGraph graph in
  case algo of
    Alphabetical -> alphabeticalColoring adjGraph
    DecreasingDegree -> decreasingDegreeColoring adjGraph
    DSatur -> dsatur adjGraph
    CustomAlgorithm ordering -> customColoring adjGraph ordering

