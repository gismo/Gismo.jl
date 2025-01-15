using BenchmarkTools
using BenchmarkPlots
using Gismo

KV = KnotVector([0.,0.,0.,1.,1.,1.])
TBB = TensorBSplineBasis(KV,KV)
uniformRefine!(TBB)
coefs = rand(size(TBB),3)
TB = TensorBSpline(TBB,coefs)

display(@benchmark normal(TB,rand(Float64, (2, 1))))
display(@benchmark val(TB,rand(Float64, (2, 1))))



