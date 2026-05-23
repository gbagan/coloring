export function zip3<A, B, C>(xs: A[], ys: B[], zs: C[]): [A, B, C][] {
  const n = Math.min(xs.length, ys.length, zs.length);
  const res = new Array(n);
  for (let i = 0; i < n; i++) {
    res[i] = [xs[i], ys[i], zs[i]];
  }
  return res;
}

export function pseudoRandom(n: number) {
  const m = 100 * Math.sin(n + 1)
  return m - Math.floor(m);
}