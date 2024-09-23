import times from "lodash.times";
import { pseudoRandom } from "./util";

export type Edge = [number, number];

function incident (v: number, [u1, u2]: Edge) {
  return v == u1 || v == u2
}

export type Position = {
  x: number,
  y: number,
}

// une structure Graph est composé d'un titre, d'une liste des arêtes et de la position de chaque sommet dans le plan
export type Graph = {
  layout: Position[],
  edges: Edge[],
}

export type AdjGraph = number[][];

export function nbVertices(graph: Graph) {
  return graph.layout.length;
}

export function getCoords(graph: Graph, u: number) {
  return graph.layout[u];
}

export function getCoordsOfEdge(graph: Graph, [u, v]: Edge) {
  const { x: x1, y: y1 } = getCoords(graph, u);
  const { x: x2, y: y2 } = getCoords(graph, v);
  return { x1, x2, y1, y2 };
}

export function addVertex(graph: Graph, pos: Position): Graph {
  return {...graph, layout: [...graph.layout, pos]}
}

export function removeVertex(graph: Graph, v: number): Graph {
  const layout = graph.layout.toSpliced(v, 1);
  const edges: Edge[] = [];
  const m = graph.edges.length;
  for (let i = 0; i < m; i++) {
    const [u1, u2] = graph.edges[i];
    if (u1 !== v && u2 !== v) {
      edges.push([u1 > v ? u1 - 1 : u1, u2 > v ? u2 - 1 : u2]);
    }
  }
  return {layout, edges};
}

export function removeEdge(graph: Graph, [u, v]: Edge): Graph {
  const edges = graph.edges.filter(([u1, v1]) => !(u == u1 && v == v1 || u == v1 && v == u1));
  return {...graph, edges}
}

export function addEdge(graph: Graph, u: number, v: number): Graph {
  if (graph.edges.some(([u1, v1]) => u == u1 && v == v1 || u == v1 && v == u1)) {
    return graph
  } else {
    return {...graph, edges: [...graph.edges, [u, v]]}
  }
}

export function toAdjGraph(graph: Graph): AdjGraph {
  const n = graph.layout.length;
  const adjgraph: AdjGraph = new Array(n);
  for (let i = 0; i < n; i++) {
    adjgraph[i] = [];
  }
  for (const [u, v] of graph.edges) {
    adjgraph[u].push(v);
    adjgraph[v].push(u);
  } 
  return adjgraph;
}

export function jsonToGraph (json: string): Graph | null {
  const isEdge = (x: any, n: number) =>
    Array.isArray(x) &&
    x.length == 2 &&
    typeof x[0] === "number" &&
    typeof x[1] === "number" &&
    x[0] >= 0 && x[1] >= 0 && x[0] < n && x[1] < n;
  
  const isPosition = (obj: any) =>
    obj !== null &&
    typeof obj === "object" &&
    typeof obj.x === "number" &&
    obj.x >= 0 && obj.x < 1 &&
    typeof obj.y === "number" &&
    obj.y >= 0 && obj.y < 1;
  
  const isValidGraph = (obj: any) => {
    if (obj === null || typeof obj !== "object" || !Array.isArray(obj.layout) || !obj.layout.every(isPosition)) {
      return false;
    }
    const n = obj.layout.length;
    return Array.isArray(obj.edges) && obj.edges.every((e: any) => isEdge(e, n));
  }

  try {
    const obj = JSON.parse(json);
    if (isValidGraph(obj)) {
      return obj as Graph;
    } else {
      return null;
    }
  } catch {
    return null;
  }
}

export const emptyGraph: () => Graph = () => ({ layout: [], edges: [] })

const graph1: () => Graph = () => ({
  layout: [
    {y: 0.08142857142857143, x: 0.18050000871930805},
    {y: 0.23285714285714285, x: 0.07621429443359375},
    {y: 0.23714285714285716, x: 0.2876428658621652},
    {y: 0.4757142857142857, x: 0.2676428658621652},
    {y: 0.6242857142857143, x: 0.08621429443359375},
    {y: 0.79, x:0.08478572300502232},
    {y: 0.9514285714285714, x: 0.28192858014787947},
    {y: 0.9557142857142857, x: 0.680500008719308},
    {y: 0.5057142857142857, x: 0.9276428658621652},
    {y: 0.6942857142857143, x: 0.5047857230050223},
    {y: 0.7, x: 0.2776428658621652},
    {y: 0.4928571428571429, x: 0.49764286586216516},
    {y: 0.20285714285714285, x: 0.5019285801478794},
    {y: 0.7071428571428572, x:0.6833571515764509},
  ],
  edges: [[1,0], [2,1], [3,2], [4,3], [5,4], [6,5], [7,6], [8,7], [9,8], [10,9], [11,10], [3,11], [12,11], [12,0], [13,9], [7,13], [10,5]]
});

const graph2: () => Graph = () => ({
  layout: [
    {y: 0.41285714285714287, x: 0.3447857230050223},
    {y: 0.5842857142857143, x: 0.2333571515764509},
    {y: 0.5814285714285714, x: 0.049071437290736604},
    {y: 0.3628571428571429, x: 0.05192858014787947},
    {y: 0.5385714285714286, x: 0.8076428658621652},
    {y: 0.5985714285714285, x: 0.660500008719308},
    {y: 0.40714285714285714, x: 0.5247857230050224},
    {y: 0.5928571428571429, x: 0.5433571515764509},
    {y: 0.9285714285714286, x: 0.5347857230050224},
    {y: 0.4642857142857143, x: 0.9590714372907366},
    {y: 0.9014285714285715, x: 0.22050000871930803},
    {y: 0.11571428571428571, x: 0.6762142944335937}
  ],
  edges: [[1,0], [1,3], [6,0], [7,6], [9,11], [5,11], [11,0], [3,11], [9,6], [8,9], [4,5], [9,4], [1,7], [10,1], [8,10], [7,8], [10,6], [2,3], [10,2], [8,5]]
});

const graph3: () => Graph = () => ({
  layout: [
    {y: 0.06714285714285714, x: 0.25050000871930805},
    {y: 0.17142857142857143, x: 0.09192858014787947},
    {y: 0.26571428571428574, x: 0.33621429443359374},
    {y: 0.05, x: 0.4490714372907366},
    {y: 0.15428571428571428, x: 0.5547857230050223},
    {y: 0.26571428571428574, x: 0.5747857230050223},
    {y: 0.45, x: 0.5762142944335937},
    {y: 0.4685714285714286, x: 0.32621429443359373},
    {y: 0.5714285714285714, x: 0.5733571515764508},
    {y: 0.7228571428571429, x: 0.5619285801478795},
    {y: 0.6614285714285715, x: 0.33192858014787946},
    {y: 0.8214285714285714, x: 0.3376428658621652},
    {y: 0.9342857142857143, x: 0.6662142944335937},
    {y: 0.9528571428571428, x: 0.09192858014787947},
    {y: 0.6385714285714286, x: 0.07764286586216518},
  ],
  edges: [[2,1], [0,2], [1,0], [3,2], [4,3], [2,4], [5,2], [6,5], [7,6], [2,7], [8,7], [9,8], [10,9], [7,10], [8,10], [9,7], [11,10], [12,11], [13,12], [14,13], [7,14]]
})

const graph4: () => Graph = () => ({
  layout: [
    {y: 0.4514285714285714, x: 0.03907143729073661},
    {y: 0.3385714285714286, x:0.14478572300502232},
    {y: 0.45285714285714285, x: 0.2247857230050223},
    {y: 0.5657142857142857, x: 0.11621429443359375},
    {y: 0.25, x: 0.3376428658621652},
    {y: 0.06285714285714286, x: 0.4633571515764509},
    {y: 0.4828571428571429, x: 0.9533571515764508},
    {y: 0.9471428571428572, x: 0.4233571515764509},
    {y: 0.6885714285714286, x: 0.330500008719308},
    {y: 0.4742857142857143, x:0.6733571515764509},
  ],
  edges: [[0,3], [2,3], [1,2], [0,1], [4,2], [5,4], [9,5], [6,5], [6,9], [7,6], [7,9], [7,8], [8,2], [4,8], [9,8], [4,9]]
});

const bigGraph: () => Graph = () => ({
  layout: times(100, i => ({ x: 0.02 + pseudoRandom(i * 2) * 0.96, y: 0.02 + pseudoRandom (i * 2 + 1) * 0.96})),
  edges: times(1000, i => [(100 * pseudoRandom (i * 2)) | 0, (100 * pseudoRandom (i * 2 + 1)) | 0])
              .filter(([u, v]) => u !== v) as Edge[]
});

function loadGraph(idx: number): Graph {
  const json = window.localStorage.getItem(`coloring-graph-${idx}`);
  if (json === null)
    return emptyGraph();
  return jsonToGraph(json) ?? emptyGraph();
}


const graphFns: (() => Graph)[] = [graph1, graph2, graph3, graph4, bigGraph, () => loadGraph(5), () => loadGraph(6), () => loadGraph(7)];

export const genGraph = (i: number) => graphFns[i]();

export const initialGraphs: Graph[] = [graph1(), graph2(), graph3(), graph4(), bigGraph(), loadGraph(5), loadGraph(6), loadGraph(7)];