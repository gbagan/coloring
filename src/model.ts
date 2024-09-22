import { alphabeticalColoring, Coloring, customColoring, decreasingDegreeColoring, dsatur, indSetColoring } from "./coloring";
import { Graph, initialGraphs, toAdjGraph } from "./graph";

type CustomAlgo = {
  type: "custom",
  ordering: number[],
}

export type Algo = { type: "alpha" | "decdegree" | "indset" | "dsatur" } | CustomAlgo;

export type Result = {
  algorithm: Algo,
  coloring: Coloring,
  nbColors: number,
  showNbColors: boolean
}

export type State = {
  selectedAlgorithm: Algo,
  results: Result[],
  currentStep: number,
  selectedResultIndex: number,
  graphs: Graph[],
  selectedGraphIdx: number,
  //editmode ∷ EditMode,
  //selectedVertex: number | undefined,
  //currentPosition: Position | undefined,
  //dialog ∷ Dialog
}

export const initState: State = {
  selectedAlgorithm: {type: "alpha"},
  results: [],
  currentStep: 0,
  selectedResultIndex: 0,
  graphs: initialGraphs,
  selectedGraphIdx: 0,
  // editmode: MoveMode
  //selectedVertex: undefined,
  //, currentPosition: Nothing
  //, dialog: NoDialog
}

function runColoring(graph: Graph, algo: Algo): Coloring | undefined {
  const adjGraph = toAdjGraph(graph);
  switch(algo.type) {
    case "alpha": return alphabeticalColoring(adjGraph)
    case "decdegree": return decreasingDegreeColoring(adjGraph)
    case "dsatur": return dsatur(adjGraph)
    case "indset": return indSetColoring(adjGraph)
    case "custom": return (
      // todo
      // if isAnOrdering (length adjGraph) ordering then
        customColoring(adjGraph, algo.ordering)
      // else
      //  Nothing
    )
  }
}

export function runBiasedColoring(idx: number, graph: Graph, algo: Algo) {
  if (idx === 1 && algo.type === "decdegree") {
    return customColoring(toAdjGraph(graph), [11, 10, 1, 9, 8, 6, 3, 0, 7, 5, 2, 4])
  } else if (idx === 1 && algo.type === "indset") {
    return customColoring(toAdjGraph(graph), [11, 10, 7, 4, 1, 6, 8, 2, 9, 5, 3, 0])
  } else {
    return runColoring(graph, algo)
  }
}