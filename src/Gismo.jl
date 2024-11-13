module Gismo

import gismo_jll:libgismo

# Forward declaration of structs
include("Declarations.jl")

# Load gsMatrix
include("gsMatrix.jl")

# Load gsCore
include("gsCore.jl")

# Load gsNurbs
include("gsNurbs.jl")

# Load gsHSplines
include("gsHSplines.jl")


end #module
