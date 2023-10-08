module GraphParams.Model where

import Relude

import Data.Lens.AffineTraversal (AffineTraversal', affineTraversal)
import Data.Char (fromCharCode, toCharCode)
import Data.String.CodeUnits (fromCharArray, singleton, toCharArray)
import GraphParams.Coloring (Coloring, alphabeticalColoring, customColoring, decreasingDegreeColoring, welshPowell, dsatur)
import GraphParams.Graph (Graph, toAdjGraph)

data EditMode = MoveMode | VertexMode | AddEMode | DeleteMode
derive instance Eq EditMode

type Position = { x ∷ Number, y ∷ Number}

data Algorithm 
  = Alphabetical
  | DecreasingDegree
  | WelshPowell
  | DSatur
  | CustomAlgorithm (Array Int)

data Dialog
  = NoDialog
  | ExportDialog String
  | ImportDialog String

labelToString ∷ Int -> String
labelToString = singleton <<< fromMaybe 'A' <<< \n -> fromCharCode (n + toCharCode 'A')

orderingToString ∷ Array Int -> String
orderingToString = fromCharArray <<< catMaybes <<< map \n -> fromCharCode (n + toCharCode 'A')

stringToOrdering ∷ String -> Maybe (Array Int)
stringToOrdering text = Just $ text # toCharArray # map (\c -> toCharCode c - toCharCode 'A')
-- todo

algoToString ∷ Algorithm -> String
algoToString Alphabetical = "Alphabétique"
algoToString DecreasingDegree = "Degré décroissant"
algoToString WelshPowell = "Welsh and Powell"
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

selectedGraph ∷ Model -> Graph
selectedGraph {graphs, selectedGraphIdx} =
  fromMaybe {layout: [], edges: []} $ graphs !! selectedGraphIdx

_graphs ∷ Lens' Model (Array Graph)
_graphs = prop (Proxy ∷ _"graphs")


_selectedGraph ∷ AffineTraversal' Model Graph
_selectedGraph = affineTraversal set pre
  where
  set ∷ Model -> Graph -> Model
  set model@{graphs, selectedGraphIdx} b =
    model { graphs = fromMaybe graphs $ updateAt selectedGraphIdx b graphs }

  pre ∷ Model -> Either Model Graph
  pre model = maybe (Left model) Right $ model.graphs !! model.selectedGraphIdx

nbVertices ∷ Model -> Int
nbVertices model = length (selectedGraph model).layout

partialColoring ∷ Model -> Array Int
partialColoring model@{currentStep, results, selectedResultIndex} =
  let
    graph = selectedGraph model
    emptyColoring = replicate (length graph.layout) (-1)
  in
  fromMaybe emptyColoring do
    {coloring} <- results !! selectedResultIndex
    let pcoloring = take currentStep coloring # map \{vertex, color} -> vertex /\ color
    pure $ updateAtIndices pcoloring emptyColoring

runColoring ∷ Graph -> Algorithm -> Coloring
runColoring graph algo =
  let adjGraph = toAdjGraph graph in
  case algo of
    Alphabetical -> alphabeticalColoring adjGraph
    DecreasingDegree -> decreasingDegreeColoring adjGraph
    DSatur -> dsatur adjGraph
    WelshPowell -> welshPowell adjGraph
    CustomAlgorithm ordering -> customColoring adjGraph ordering
