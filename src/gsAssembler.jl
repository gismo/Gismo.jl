export
    QuadRule,
    GaussRule,
    LobattoRule,
    destroy!,
    show,
    numNodes,
    dim,
    mapTo,
    mapTo
    #= TODO =#

########################################################################
# gsQuadRule
########################################################################

"""
A struct that represents a quadrature rule
"""
mutable struct QuadRule
    ptr::Ptr{gsCQuadRule}

    function QuadRule(quad::Ptr{gsCQuadRule},delete::Bool=true)
        b = new(quad)
        if (delete)
            finalizer(destroy!,b)
        end
        return b
    end

    #= This function depends on Basis and OptionList, which are dependencies. Can we do some forward declarations, or should we take care of this in the ordering in Declaraions.jl? =#
    # function QuadRule(basis::Basis, options::OptionList, fixDirection::Bool=false)
    #     quad = ccall((:gsQuadRule_get,libgismo),Ptr{gsCQuadRule},(Ptr{gsCBasis},Ptr{gsCOptionList},Cint),basis.ptr,options.ptr,Int(fixDirection))
    #     return QuadRule(quad)
    # end

    function destroy!(qr::QuadRule)
        ccall((:gsQuadRule_delete,libgismo),Cvoid,(Ptr{gsCQuadRule},),qr.ptr)
    end
end

"""
Returns a Gauss rule for numerical integration

# Arguments
- `d::Int`: the dimension of the rule
- `numNodes::Array{Int}`: a vector of length `d` with the number of points in each direction
- `digits::Int`: the number of digits of precision for the rule (optionals)

"""
function GaussRule(d::Cint, numNodes::Array{Cint}, digits::Cint=Cint(0))::QuadRule
    @assert d == length(numNodes) "GaussRule: numNodes must have the same size as the dimension"
    qr = ccall((:gsGaussRule_create,libgismo),Ptr{gsCQuadRule},(Cint,Ptr{Cint},Cint),d,numNodes,digits)
    return QuadRule(qr)
end

"""
Returns a Gauss rule for numerical integration

# Arguments
- `numNodes::Int`: the number of points in each direction
- `digits::Int`: the number of digits of precision for the rule (optionals)

"""
function GaussRule(numNodes::Cint, digits::Cint=Cint(0))::QuadRule
    d::Cint = 1;
    numNodesVec::Array{Cint} = [numNodes]
    qr = ccall((:gsGaussRule_create,libgismo),Ptr{gsCQuadRule},(Cint,Ptr{Cint},Cint),d,numNodesVec,digits)
    return QuadRule(qr)
end

"""
Returns a Lobatto rule for numerical integration

# Arguments
- `d::Int`: the dimension of the rule
- `numNodes::Array{Int}`: a vector of length `d` with the number of points in each direction
- `digits::Int`: the number of digits of precision for the rule (optionals)

"""
function LobattoRule(d::Cint, numNodes::Array{Cint}, digits::Cint=Cint(0))::QuadRule
    @assert d == length(numNodes) "LobattoRule: numNodes must have the same size as the dimension"
    qr = ccall((:gsLobattoRule_create,libgismo),Ptr{gsCQuadRule},(Cint,Ptr{Cint},Cint),d,numNodes,digits)
    return QuadRule(qr)
end

"""
Returns a Lobatto rule for numerical integration

# Arguments
- `numNodes::Int`: the number of points in each direction
- `digits::Int`: the number of digits of precision for the rule (optionals)

"""
function LobattoRule(numNodes::Int, digits::Int=Cint(0))::QuadRule
    d::Int = 1;
    numNodesVec::Array{Int} = [numNodes]
    qr = ccall((:LobattoRule_create,libgismo),Ptr{gsCQuadRule},(Cint,Ptr{Cint},Cint),d,numNodesVec,digits)
    return QuadRule(qr)
end

"""
Returns the number of nodes

# Arguments
- `qr::QuadRule`: the quad rule

"""
function numNodes(qr::QuadRule)
    return ccall((:gsQuadRule_numNodes,libgismo),Cint,(Ptr{gsCQuadRule},),qr.ptr)
end

"""
Returns the dimension of the quad rule

# Arguments
- `qr::QuadRule`: the quad rule

"""
function dim(qr::QuadRule)
    return ccall((:gsQuadRule_dim,libgismo),Cint,(Ptr{gsCQuadRule},),qr.ptr)
end

"""
Maps the quad rule to a given interval

# Arguments
- `qr::QuadRule`: the quad rule
- `lower::Vector{Cdouble}`: the lower bound of the interval
- `upper::Vector{Cdouble}`: the upper bound of the interval

"""
function mapTo(qr::QuadRule, lower::Vector{Cdouble}, upper::Vector{Cdouble})::Tuple{EigenMatrix,EigenMatrix}
    @assert length(lower) == length(upper) == dim(qr) "mapTo: lower and upper must have the same size as the dimension of the quad rule"
    nodes = EigenMatrix();
    weights = EigenMatrix();
    low = EigenMatrix(Base.size(lower,1),1,pointer(lower));
    upp = EigenMatrix(Base.size(upper,1),1,pointer(upper));
    ccall((:gsQuadRule_mapTo,libgismo),Cvoid,
        (Ptr{gsCQuadRule},Ptr{gsCMatrix},Ptr{gsCMatrix},Ptr{gsCMatrix},Ptr{gsCMatrix}),
        qr.ptr,low.ptr,upp.ptr,nodes.ptr,weights.ptr)
    return nodes, weights
end

"""
Maps the quad rule to a given interval

# Arguments
- `qr::QuadRule`: the quad rule
- `startVal::Cdouble`: the lower bound of the interval
- `endVal::Cdouble`: the upper bound of the interval

"""
function mapTo(qr::QuadRule, startVal::Cdouble, endVal::Cdouble)::Tuple{EigenMatrix,EigenMatrix}
    @assert startVal < endVal "mapTo: startVal must be smaller than endVal"
    nodes = EigenMatrix();
    weights = EigenMatrix();
    ccall((:gsQuadRule_mapToScalar,libgismo),Cvoid,
        (Ptr{gsCQuadRule},Cdouble,Cdouble,Ptr{gsCMatrix},Ptr{gsCMatrix}),
        qr.ptr,startVal,endVal,nodes.ptr,weights.ptr)
    return nodes, weights
end