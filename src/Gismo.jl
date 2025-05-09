# Import Base.size to be able to overload it
import Base.size

module Gismo

import gismo_jll:libgismo

# Forward declaration of structs
include("Declarations.jl")

# Load gsCore
include("gsCore.jl")

# Load gsMatrix
include("gsMatrix.jl")

# Load gsAssembler
include("gsAssembler.jl")

# Load gsHSplines
include("gsHSplines.jl")

# Load gsIO
include("gsIO.jl")

# Load gsMatrix
include("gsModeling.jl")

# Load gsNurbs
include("gsNurbs.jl")

end #module
