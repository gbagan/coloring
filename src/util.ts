export function replicate<A>(size: number, val: A): A[] {
  const a = new Array(size);
  a.fill(val);
  return a;
}

export function pseudoRandom(n: number): number {
  const m = 100 * Math.sin(n + 1);
  return m - Math.floor(m);
}