using Gismo
using Plots

# Generate random parameters and points
num_points = 1000
pars = rand(Float64,(num_points, 2))  # 2D parameters in [0, 1] interval
points = zeros(Float64,(num_points, 3))  # 3D points
# Define the radius of the circle
radius = 0.25

# Generate points
for i in 1:num_points
    x, y = pars[i, :]
    z = ifelse((x - 0.5)^2 + (y - 0.5)^2 <= radius^2, 1.0, 0.0)
    points[i, :] = [x, y, z]
end
pars=Matrix(pars')
points=Matrix(points')

# Create the knot vector
KV = KnotVector([0.,0.,0.,1.,1.,1.])
# Define the basis using the knots
BB2 = TensorBSplineBasis(KV, KV)
uniformRefine!(BB2)
uniformRefine!(BB2)
uniformRefine!(BB2)

# Create the fitter
fitter = Fitting(pars, points, BB2)
# Perform the parameter correction
parameterCorrection!(fitter)
# Perform the least squares error approximation
compute!(fitter)
# Compute the errors
computeErrors!(fitter)
# Display the outputs
println("Minimum point error: ", minPointError(fitter))
println("Maximum point error: ", maxPointError(fitter))
println("Pointwise errors: ", unsafe_wrap(Vector{Float64}, pointWiseErrors(fitter), num_points, own=false))

println("Number of points under the tolleance of 0.1: ",numPointsBelow(fitter, 0.1))
# Obtain the geometry
geo = result(fitter)
# Create a matrix of linearly spaced evaluation points
N = 10
points1D = range(0,stop=1,length=N)
points2D = zeros(2,N*N)
# Create a meshgrid of evaluation points
points2D[1,:] = repeat(points1D, N)
points2D[2,:] = repeat(points1D, inner=N)
ev = asMatrix(val(geo,points2D))
# Plot the geometry
scatter(points[1,:],points[2,:],points[3,:],legend=false)
surface!(ev[1,:],ev[2,:],ev[3,:],legend=false)
gui()
# Press enter to exit
println("Press enter to exit!")
readline()