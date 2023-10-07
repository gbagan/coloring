const colorWithFirstAvailable = (graph, colors, u) => {
    const adjColors = new Set(graph[u].map(v => colors[v]))
    let availableColor = 0
    while(adjColors.has(availableColor)) {
        availableColor++
    }
    colors[u] = availableColor
    return availableColor
}

export const customColoring = graph => ordering => {
    const colors = new Array(ordering.length)
    colors.fill(-1)
    for (const vertex of ordering) {
        colorWithFirstAvailable(graph, colors, vertex)
    }
    return ordering.map(v => ({vertex: v, color: colors[v]}))
}

const dsaturStep = (graph, colors) => {
    let bestCandidate = null
    for (let u = 0; u < graph.length; u++) {
        if (colors[u] !== -1)
            continue
        degree = graph[u].length
        saturation = (new Set(graph[u].map(w => colors[w]))).size
        if (bestCandidate === null
            || bestCandidate.saturation < saturation 
            || bestCandidate.saturation === saturation && bestCandidate.degree < degree 
            ) {
                bestCandidate = { vertex: u, saturation, degree }
            }
    }
    return bestCandidate.vertex
}

export const dsatur = graph => {
    const colors = new Array(graph.length)
    const result = []
    colors.fill(-1)
    for (let i = 0; i < graph.length; i++) {
        const v = dsaturStep(graph, colors)
        const c = colorWithFirstAvailable(graph, colors, v)
        result.push({ vertex: v, color: c })
    }
    return result
}

export const welshPowellImpl = graph => order => {
    const result = []
    let color = 0
    while(result.length < graph.length) {
        const adjArray = new Array(graph.length)
        adjArray.fill(false)
        for (const v of order) {
            if (adjArray[v])
                continue
            result.push({ vertex: v, color})
            for (const u of graph[v])
                adjArray[u] = true
        }
        color++
    }
    return result
}