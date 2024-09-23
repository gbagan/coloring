import { Graph } from "./graph";

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

export function jsonToGraph (json: string): Graph | null {
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