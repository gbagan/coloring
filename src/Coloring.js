export const indSetColoringImpl = graph => order => {
    const result = []
    let color = 0
    const colored = new Array(graph.length)
    colored.fill(false)
    while(result.length < graph.length) {
        const adjArray = new Array(graph.length)
        adjArray.fill(false)
        for (const v of order) {
            if (colored[v] || adjArray[v])
                continue
            result.push({ vertex: v, color})
            colored[v] = true
            for (const u of graph[v])
                adjArray[u] = true
        }
        color++
    }
    return result
}