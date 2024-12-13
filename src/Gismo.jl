module Gismo

libgismo = "/Users/none/gismo2/gismo/build/lib/libgismo"

# Forward declaration of structs
include("Declarations.jl")

# Load gsAssembler
include("gsAssembler.jl")

# Load gsCore
include("gsCore.jl")

# Load gsHSplines
include("gsHSplines.jl")

# Load gsIO
include("gsIO.jl")

# Load gsMatrix
include("gsMatrix.jl")

# Load gsMatrix
include("gsModeling.jl")

# Load gsNurbs
include("gsNurbs.jl")

end #module
