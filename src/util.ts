export function pseudoRandom(n: number): number {
  const m = 100 * Math.sin(n + 1);
  return m - Math.floor(m);
}