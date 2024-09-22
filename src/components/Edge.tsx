import { Component } from "solid-js"

type EdgeComponent = Component<{
  coords: {x1: number, x2: number, y1: number, y2: number},
  onClick: () => void
}>
  
const Edge: EdgeComponent = props =>
  <line
    x1={100 * props.coords.x1}
    x2={100 * props.coords.x2}
    y1={100 * props.coords.y1}
    y2={100 * props.coords.y2}
    stroke-width="0.5"
    class="stroke-blue-500"
    onClick={props.onClick}
  />

export default Edge;