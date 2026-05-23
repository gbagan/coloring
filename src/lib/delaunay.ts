import { partition } from "@gbagan/utils";

type Point = { x: number, y: number };
type Triangle = [number, number, number];

function areClockwise(a: Point, b: Point, c: Point) {
  return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x) >= 0;
}

// p est-il à l'intérieur du cercle circonscrit à abc ? (strictement, pas sur le cercle)
function inCircle(a: Point, b: Point, c: Point, p: Point) {
  const ax = a.x - p.x;
  const ay = a.y - p.y;
  const bx = b.x - p.x;
  const by = b.y - p.y;
  const cx = c.x - p.x;
  const cy = c.y - p.y;

  const det =
    (ax * ax + ay * ay) * (bx * cy - cx * by) -
    (bx * bx + by * by) * (ax * cy - cx * ay) +
    (cx * cx + cy * cy) * (ax * by - bx * ay);

  return det > 0;
}

const edgeKey = (a: number, b: number, n: number) => a < b ? a*n+b : b*n+a;

export function delaunay(points: Point[]): [number, number][] {
  if (points.length < 3) return [];

  const n = points.length;

  const clockwiseTriangle = (i1: number, i2: number, i3: number): Triangle =>
    areClockwise(points[i1], points[i2], points[i3]) ? [i1, i2, i3] : [i3, i2, i1];

  const p1 = {x: -2, y: -1 };
  const p2 = {x: 0.5, y: 2 };
  const p3 = {x: 3, y: -1 };

  points = [...points, p1, p2, p3];

  let triangles: Triangle[] = [clockwiseTriangle(n, n+1, n+2)];

  points.forEach((point, i) => {
    const [bad, good] = partition(triangles, ([i1, i2, i3]) =>
      inCircle(points[i1], points[i2], points[i3], point)
    );

    const edgeMap = new Map<number, [number, number]>();

    for (const [i1, i2, i3] of bad) {
      for (const [a, b] of [[i1, i2], [i2, i3], [i3, i1]]) {
        const key = edgeKey(a, b, n);
        if (edgeMap.has(key)) {
          edgeMap.delete(key);
        } else {
          edgeMap.set(key, [a, b]);
        }
      }
    }

    triangles = good;

    for (const [i1, i2] of edgeMap.values()) {
      triangles.push(clockwiseTriangle(i1, i2, i));
    }
  })

  const edges: [number, number][] = [];
  const seen: Set<number> = new Set();
  for (const [i1, i2, i3] of triangles) {
    for (const [i, j] of [[i1, i2], [i2, i3], [i3, i1]]) {
      if (i < n && j < n && !seen.has(edgeKey(i, j, n))) {
        seen.add(edgeKey(i, j, n));
        edges.push([i, j]);
      }
    }
  }
  return edges;
}