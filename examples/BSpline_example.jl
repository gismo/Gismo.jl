using Plots
using Gismo

BB = KnotVector([0.0, 0.0, 0.0, 1.0, 1.0, 1.0]) |> BSplineBasis
uniformRefine!(BB)
uniformRefine!(BB)

# Create a matrix of random coefficients
CC = rand(size(BB), 2)
# Create a BSpline geometry
B = BSpline(BB, CC)

# Create a matrix of linearly spaced evaluation points
points1D = zeros(1, 3)
points1D[1, :] = range(0; stop = 1, length = 3)
evMat = val(B, points1D) # this is a C++ pointer
ev = copyMatrix(evMat) # convert to a Julia matrix (not owning the data)

# Plot the geometry
p=plot(ev[1, :], ev[2, :]; legend = false)
plot!(p, CC[:, 1], CC[:, 2]; legend = false)
plot!(p, CC[:, 1], CC[:, 2]; legend = false, seriestype = :scatter)
display(p)
