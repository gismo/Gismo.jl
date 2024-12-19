using Gismo

# Gauss quadrature rule (1D)
rule1D = GaussRule(2)
nodes,weights = mapTo(rule1D,0.0,1.0)
println("Gauss nodes: ",asMatrix(nodes))
println("Gauss nodes: ",asVector(weights))

# Lobatto quadrature rule (2D)
rule2D = LobattoRule(2,Array{Int}([2,2]))
low = Vector{Float64}([0.0,0.0])
upp = Vector{Float64}([1.0,1.0])
nodes,weights = mapTo(rule2D,low,upp)
println("Lobatto nodes: ",asMatrix(nodes))
println("Lobatto weights: ",asVector(weights))
