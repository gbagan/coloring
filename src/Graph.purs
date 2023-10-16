module GraphParams.Graph where

import Relude
import Data.Array (modifyAtIndices)
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.Argonaut.Decode (class DecodeJson, decodeJson)
import GraphParams.Util (repeat, pseudoRandom)

data Edge
  = Edge Int Int

infix 3 Edge as ↔

instance Eq Edge where
  eq (u1 ↔ v1) (u2 ↔ v2) = u1 == u2  && v1 == v2 || u1 == v2 && u2 == v1


instance EncodeJson Edge where
  encodeJson (u ↔ v) = encodeJson (u /\ v)

instance DecodeJson Edge where
  decodeJson json = do
    (u /\ v) <- decodeJson json
    pure (u ↔ v)

incident ∷ Int → Edge → Boolean
incident v (u1 ↔ v1) = v == u1 || v == v1

type Position
  = { x ∷ Number
    , y ∷ Number
    }

-- | une structure Graph est composé d'un titre, d'une liste des arêtes et de la position de chaque sommet dans le plan
type Graph
  = { layout ∷ Array Position
    , edges ∷ Array Edge
    }

type AdjGraph
  = Array (Array Int)

getCoords ∷ Graph → Int → Maybe Position
getCoords graph u = graph.layout !! u

getCoordsOfEdge ∷ Graph → Edge → Maybe { x1 ∷ Number, x2 ∷ Number, y1 ∷ Number, y2 ∷ Number }
getCoordsOfEdge graph (u ↔ v) = do
  { x: x1, y: y1 } ← getCoords graph u
  { x: x2, y: y2 } ← getCoords graph v
  pure { x1, x2, y1, y2 }

addVertex ∷ Position → Graph → Graph
addVertex pos graph = graph { layout = graph.layout `snoc` pos }

removeVertex ∷ Int → Graph → Graph
removeVertex i graph =
  graph
    { layout = fromMaybe graph.layout $ graph.layout # deleteAt i
    , edges =
      graph.edges
        # mapMaybe \(u ↔ v) →
            if u == i || v == i then
              Nothing
            else
              Just $ (if u > i then u - 1 else u) ↔ (if v > i then v - 1 else v)
    }

removeEdge ∷ Int → Int → Graph → Graph
removeEdge u v graph = graph { edges = graph.edges # filter (_ /= (u ↔ v)) }

moveVertex ∷ Int → Position → Graph → Graph
moveVertex i pos graph = graph { layout = graph.layout # updateAtIndices [ i /\ pos ] }

addEdge ∷ Int → Int → Graph → Graph
addEdge u v graph =
  graph
    { edges =
      if u == v || (u ↔ v) `elem` graph.edges then
        graph.edges
      else
        graph.edges `snoc` (u ↔ v)
    }

toAdjGraph ∷ Graph → AdjGraph
toAdjGraph g =
  foldr
    (\(u ↔ v) → modifyAtIndices [ u ] (_ `snoc` v) <<< modifyAtIndices [ v ] (_ `snoc` u))
    (g.layout <#> const [])
    g.edges

emptyGraph ∷ Graph
emptyGraph = { layout: [], edges: [] }

bigGraph ∷ Graph
bigGraph =
  { layout: repeat 100 \i → { x: pseudoRandom (i * 2), y: pseudoRandom (i * 2 + 1) }
  , edges: (repeat 1000 \i → floor (100.0 * pseudoRandom (i * 2)) ↔ floor (100.0 * pseudoRandom (i * 2 + 1)))
            # filter \(u ↔ v) → u /= v
  }

graph1 ∷ Graph
graph1 =
  { layout:
      [ {y: 0.08142857142857143, x: 0.18050000871930805}
      , {y: 0.23285714285714285, x: 0.07621429443359375}
      , {y: 0.23714285714285716, x: 0.2876428658621652}
      , {y: 0.4757142857142857, x: 0.2676428658621652}
      , {y: 0.6242857142857143, x: 0.08621429443359375}
      , {y: 0.79, x:0.08478572300502232}
      , {y: 0.9514285714285714, x: 0.28192858014787947}
      , {y: 0.9557142857142857, x: 0.680500008719308}
      , {y: 0.5057142857142857, x: 0.9276428658621652}
      , {y: 0.6942857142857143, x: 0.5047857230050223}
      , {y: 0.7, x: 0.2776428658621652}
      , {y: 0.4928571428571429, x: 0.49764286586216516}
      , {y: 0.20285714285714285, x: 0.5019285801478794}
      , {y: 0.7071428571428572, x:0.6833571515764509}
      ]
  , edges: [1↔0, 2↔1, 3↔2, 4↔3, 5↔4, 6↔5, 7↔6, 8↔7, 9↔8, 10↔9, 11↔10, 3↔11, 12↔11, 12↔0, 13↔9, 7↔13, 10↔5]
  }

graph2 ∷ Graph
graph2 =
  { layout: 
      [ {y: 0.41285714285714287, x: 0.3447857230050223}
      , {y: 0.5842857142857143, x: 0.2333571515764509}
      , {y: 0.5814285714285714, x: 0.049071437290736604}
      , {y: 0.3628571428571429, x: 0.05192858014787947}
      , {y: 0.5385714285714286, x: 0.8076428658621652}
      , {y:0.5985714285714285, x: 0.660500008719308}
      , {y:0.40714285714285714, x: 0.5247857230050224}
      , {y:0.5928571428571429, x: 0.5433571515764509}
      , {y:0.9285714285714286, x: 0.5347857230050224}
      , {y:0.4642857142857143, x: 0.9590714372907366}
      , {y:0.9014285714285715, x: 0.22050000871930803}
      , {y:0.11571428571428571, x: 0.6762142944335937}]
  , edges: [1↔0, 6↔0, 7↔6, 9↔11, 5↔11, 11↔0, 3↔11, 9↔6, 8↔9, 4↔5, 9↔4, 1↔7, 10↔1, 8↔10, 7↔8, 10↔6, 2↔3, 10↔2, 8↔5]
  }

graph3 ∷ Graph
graph3 =
  { layout:
    [ {y: 0.06714285714285714, x: 0.25050000871930805}
    , {y: 0.17142857142857143, x: 0.09192858014787947}
    , {y: 0.26571428571428574, x: 0.33621429443359374}
    , {y: 0.05, x: 0.4490714372907366}
    , {y: 0.15428571428571428, x: 0.5547857230050223}
    , {y: 0.26571428571428574, x: 0.5747857230050223}
    , {y: 0.45, x: 0.5762142944335937}
    , {y: 0.4685714285714286, x: 0.32621429443359373}
    , {y: 0.5714285714285714, x: 0.5733571515764508}
    , {y: 0.7228571428571429, x: 0.5619285801478795}
    , {y: 0.6614285714285715, x: 0.33192858014787946}
    , {y: 0.8214285714285714, x: 0.3376428658621652}
    , {y: 0.9342857142857143, x: 0.6662142944335937}
    , {y: 0.9528571428571428, x: 0.09192858014787947}
    , {y: 0.6385714285714286, x: 0.07764286586216518}
    ]
  , edges: [2↔1, 0↔2, 1↔0, 3↔2, 4↔3, 2↔4, 5↔2, 6↔5, 7↔6, 2↔7, 8↔7, 9↔8, 10↔9, 7↔10, 8↔10, 9↔7, 11↔10, 12↔11, 13↔12, 14↔13, 7↔14]
  }

graph4 ∷ Graph
graph4 =
  { layout:
    [ {y: 0.4514285714285714, x: 0.03907143729073661}
    , {y: 0.3385714285714286, x:0.14478572300502232}
    , {y: 0.45285714285714285, x: 0.2247857230050223}
    , {y: 0.5657142857142857, x: 0.11621429443359375}
    , {y: 0.25, x: 0.3376428658621652}
    , {y: 0.06285714285714286, x: 0.4633571515764509}
    , {y: 0.4828571428571429, x: 0.9533571515764508}
    , {y: 0.9471428571428572, x: 0.4233571515764509}
    , {y: 0.6885714285714286, x: 0.330500008719308}
    , {y: 0.4742857142857143, x:0.6733571515764509}
    ]
  , edges: [3↔0, 2↔3, 1↔2, 0↔1, 4↔2, 5↔4, 9↔5, 6↔5, 6↔9, 7↔6, 7↔9, 7↔8, 8↔2, 4↔8, 9↔8, 4↔9]
  }


initialGraphs ∷ Array Graph
initialGraphs = [graph1, graph2, graph3, graph4, bigGraph, emptyGraph, emptyGraph, emptyGraph]