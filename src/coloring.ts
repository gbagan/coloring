import range from "lodash.range";
import { AdjGraph } from "./graph"
import zip from "lodash.zip";
import uniq from "lodash.uniq";
import maxBy from "lodash.maxby";

export type Coloring = { vertex: number, color: number }[];

function firstAvailableColor(graph: AdjGraph, coloring: number[], u: number): number {
  const adjColors = graph[u].map(v => coloring[v]);
  for (let i = 0;; i++) {
    if (!adjColors.includes(i)) {
      return i;
    }
  }
}

function colorWithFirstAvailable(graph: AdjGraph, coloring: number[], u: number) {
  const c = firstAvailableColor(graph, coloring, u);
  coloring[u] = c;
  return c;
}

export function customColoring(graph: AdjGraph, ordering: number[]): Coloring {
  const n = ordering.length;
  const coloring = new Array(n);
  coloring.fill(-1);
  for (const v of ordering) {
    colorWithFirstAvailable(graph, coloring, v);
  }
  return ordering.map(v => ({vertex: v, color: coloring[v]}))
}

export function alphabeticalColoring(graph: AdjGraph): Coloring {
  return customColoring(graph, range(0, graph.length));
}

export function decreasingDegreeColoring(graph: AdjGraph): Coloring { 
  const ordering = range(0, graph.length).toSorted((a, b) => graph[b].length - graph[a].length);
  return customColoring(graph, ordering);
}

export function indSetColoring(graph: AdjGraph): Coloring {
  const ordering = range(0, graph.length).toSorted((a, b) => graph[b].length - graph[a].length);
  const result: Coloring = [];
  let color = 0;
  const colored: boolean[] = new Array(graph.length);
  colored.fill(false);
  while(result.length < graph.length) {
    const adjArray: boolean[] = new Array(graph.length);
    adjArray.fill(false);
    for (const v of ordering) {
      if (colored[v] || adjArray[v])
        continue
      result.push({ vertex: v, color});
      colored[v] = true;
      for (const u of graph[v]) {
        adjArray[u] = true;
      }
    }
    color++;
  }
  return result
}

function dsaturStep(graph: AdjGraph, colors: number[]): number | undefined {
  const order =
    zip(range(0, graph.length), graph, colors) 
    .filter(([,,color]) => color === -1)
    .map(([v, nbor]) => ({
      vertex: v!,
      saturation: uniq(nbor!.map(v => colors[v]).filter(c => c !== -1)).length,
      degree: nbor!.length,
    }));
  return maxBy(order, o=>o.saturation*10000+o.degree)?.vertex
}

export function dsatur(graph: AdjGraph): Coloring {
  const colors: number[] = new Array(graph.length);
  colors.fill(-1);
  const result: Coloring = []; 
  while(true) {
    let v = dsaturStep(graph, colors);
    if (v === undefined) {
        break;
    }
    const c = colorWithFirstAvailable(graph, colors, v);
    result.push({vertex: v, color: c});
  }
  return result
}