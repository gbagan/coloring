import { arrayOf, filterMap, maxBy, range } from "@gbagan/utils";
import { zip3 } from './util'
import type { AdjGraph } from "./graph";

export type Coloring = { vertex: number, color: number }[];

function firstAvailableColor(graph: AdjGraph, coloring: number[], u: number): number {
  const adjColors = graph[u].map(v  => coloring[v]);
  let i = 0;
  while(true) {
    if(!adjColors.includes(i)) {
      return i;
    }
    i++;
  }
}

function colorWithFirstAvailable(graph: AdjGraph, coloring: number[], u: number) {
  const c = firstAvailableColor(graph, coloring, u)
  coloring[u] = c;
  return c;
}

export function customColoring(graph: AdjGraph, ordering: number[]): Coloring {
  const coloring = arrayOf(ordering.length, -1)
  for (const v of ordering) {
    colorWithFirstAvailable(graph, coloring, v);
  }
  return ordering.map(v => ({vertex: v, color: coloring[v]}));
}

export const alphabeticalColoring = (graph: AdjGraph) =>
  customColoring(graph, range(0, graph.length));

export function decreasingDegreeColoring(graph: AdjGraph) { 
  const ordering = range(0, graph.length).sort((a, b) => graph[b].length - graph[a].length);
  return customColoring(graph, ordering)
}

export function indSetColoring(graph: AdjGraph) {
  const ordering = range(0, graph.length).sort((a, b) => graph[b].length - graph[a].length);
  const result: Coloring = [];
  let color = 0;
  const colored = arrayOf(graph.length, false);
  while (result.length < graph.length) {
    const adjArray = arrayOf(graph.length, false);
    for (const v of ordering) {
      if(colored[v] || adjArray[v]) continue
      result.push({ vertex: v, color});
      colored[v] = true;
      for (const u of graph[v]) {
        adjArray[u] = true;
      }
    }
    color++;
  }
  return result;
}

const nbDistinct = (xs: number[]) => new Set(xs).size;

function dsaturStep(graph: AdjGraph, colors: number[]): number | null {
  const order =
    filterMap(zip3(range(0, graph.length), graph, colors), ([v, nbor, color]) =>
      color !== -1
      ? null
      : {
        vertex: v,
        saturation: nbDistinct(filterMap(nbor, v => colors[v] === -1 ? null : colors[v])),
        degree: nbor.length,
      }
    );
  return maxBy(order, o=>o.saturation*10000+o.degree)?.vertex ?? null
}

export function dsatur(graph: AdjGraph) {
  const colors = arrayOf(graph.length, -1);
  const result: Coloring = [];
  while (true) {
    const v = dsaturStep(graph, colors);
    if (v === null) return result;
    const c = colorWithFirstAvailable(graph, colors, v);
    result.push({vertex: v, color: c});
  }
}