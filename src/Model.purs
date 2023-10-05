module GraphParams.Model where

import Prelude

import Data.Array ((!!), catMaybes, length, replicate, take, updateAtIndices)
import Data.Char (fromCharCode, toCharCode)
import Data.String.CodeUnits (fromCharArray)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Tuple.Nested ((/\))
import GraphParams.Coloring (Coloring, alphabeticalColoring, customColoring, decreasingDegreeColoring, dsatur)
import GraphParams.Graph (Graph, toAdjGraph)

data EditMode = MoveMode | VertexMode | AddEMode | DeleteMode
derive instance Eq EditMode

type Position = { x ∷ Number, y ∷ Number}

data Algorithm = Alphabetical | DecreasingDegree | DSatur | CustomAlgorithm (Array Int)

orderingToString :: Array Int -> String
orderingToString = fromCharArray <<< catMaybes <<< map \n -> fromCharCode (n + toCharCode 'A')

algoToString :: Algorithm -> String
algoToString Alphabetical = "alphabétique"
algoToString DecreasingDegree = "degré décroissant"
algoToString DSatur = "DSatur"
algoToString (CustomAlgorithm ord) = orderingToString ord

type Result = { algorithm :: Algorithm, coloring :: Coloring, number :: Int }

type Model =
  { selectedAlgorithm ∷ Algorithm
  , results ∷ Array Result
  , currentStep ∷ Int
  , currentResultIndex ∷ Int
  , graph ∷ Graph
  , editmode ∷ EditMode
  , selectedVertex ∷ Maybe Int
  , currentPosition ∷ Maybe Position
  }

init ∷ Model
init =
  { selectedAlgorithm: DSatur
  , results: []
  , currentStep: 0
  , currentResultIndex: 0
  , graph: {layout: [], edges: []}
  , editmode: VertexMode
  , selectedVertex: Nothing
  , currentPosition: Nothing
  }

nbVertices :: Model -> Int
nbVertices {graph} = length graph.layout

partialColoring :: Model -> Array Int
partialColoring {graph, currentStep, results, currentResultIndex} =
  let emptyColoring = replicate (length graph.layout) (-1)
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