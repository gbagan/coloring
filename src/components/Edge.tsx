import { Component } from "solid-js"

type EdgeComponent = Component<{
  coords: {x1: number, x2: number, y1: number, y2: number},
  onClick: () => void
}>
  
const Edge: EdgeComponent = props =>
  <line
    x1={200 * props.coords.x1}
    x2={200 * props.coords.x2}
    y1={200 * props.coords.y1}
    y2={200 * props.coords.y2}
    class="stroke-1 stroke-blue-500 edge"
    onClick={props.onClick}
  />

export default Edge;