import { alphabeticalColoring, Coloring, customColoring, decreasingDegreeColoring, dsatur, indSetColoring } from "./coloring";
import { Graph, initialGraphs, toAdjGraph } from "./graph";

const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

export type CustomAlgo = {
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
  //dialog: Dialog
}

export const initState: State = {
  selectedAlgorithm: {type: "alpha"},
  results: [],
  currentStep: 0,
  selectedResultIndex: 0,
  graphs: initialGraphs,
  selectedGraphIdx: 0,
  //, dialog: NoDialog
}

function runColoring(graph: Graph, algo: Algo): Coloring | null {
  const adjGraph = toAdjGraph(graph);
  switch(algo.type) {
    case "alpha": return alphabeticalColoring(adjGraph)
    case "decdegree": return decreasingDegreeColoring(adjGraph)
    case "dsatur": return dsatur(adjGraph)
    case "indset": return indSetColoring(adjGraph)
    case "custom": return customColoring(adjGraph, algo.ordering);
  }
}

export function runBiasedColoring(idx: number, graph: Graph, algo: Algo): Coloring | null {
  if (idx === 1 && algo.type === "decdegree") {
    return customColoring(toAdjGraph(graph), [11, 10, 1, 9, 8, 6, 3, 0, 7, 5, 2, 4])
  } else if (idx === 1 && algo.type === "indset") {
    return customColoring(toAdjGraph(graph), [11, 10, 7, 4, 1, 6, 8, 2, 9, 5, 3, 0])
  } else {
    return runColoring(graph, algo)
  }
}

export const orderingToString = (ordering: number[]) => ordering.map(c => alphabet[c]).join("");

export function stringToOrdering(text: string): number[] | null {
  const a = "A".charCodeAt(0);
  const z = "Z".charCodeAt(0);
  text = text.toUpperCase();
  const n = text.length;
  const res = [];
  for (let i = 0; i < n; i++) {
    let code = text.charCodeAt(i);
    if (code < a || code > z) {
      return null;
    }
    res.push(code - a);
  }
  return res;
}

export function isValidOrdering(ordering: number[]): boolean {
  console.log(ordering.toSorted((a, b) => a - b));
  return ordering.toSorted((a, b) => a - b).every((i, j) => i === j);
} 