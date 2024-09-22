import { Component, For, Show } from 'solid-js';
import {getCoordsOfEdge, Graph} from './graph';
import { colors } from './colors';

const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

type GraphComponent = Component<{
  graph: Graph,
  colors: number[],
}>;

const GraphView: GraphComponent = props => {
  return (
    <div>
      <div class="w-3xl h-3xl">
        <svg
          viewBox="0 0 100 100"
          class="block"
        >
          <For each={props.graph.edges}>
            {edge => {
              const {x1, x2, y1, y2} = getCoordsOfEdge(props.graph, edge);
              return (
                <line
                  x1={100*x1}
                  x2={100*x2}
                  y1={100*y1}
                  y2={100*y2}
                  stroke-width="0.5"
                  class="stroke-blue-500"
                />
              )
            }}
          </For>
          <For each={props.graph.layout}>
            {({x, y}, i) => (
              <circle
                cx={100*x}
                cy={100.0*y}
                r="4"
                stroke-width="0.5"
                stroke="black"
                class={colors[props.colors[i()]] ?? "fill-white"}
              />
            )}
          </For>
          <Show when={props.graph.layout.length <= 26}>
            <For each={props.graph.layout}>
              {({x, y}, i) => (
                <text
                  x={100*x-2}
                  y={100*y+2}
                  class="graphtext pointer-events-none select-none"
                >
                  {alphabet[i()]}
                </text>
              )}
            </For>
          </Show>
        </svg>
      </div>
    </div>
  )
}

export default GraphView;