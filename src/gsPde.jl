export
       BoundaryConditions,
       addCondition!,
       addCornerValue!,
       setGeoMap!
# Basis,
# show,
# destroy!,
# domainDim,
# targetDim,
# component,
# degree,
# numElements,
# size,
# uniformRefine!,
# refineElements!,
# refine!,
# actives,
# val,
# deriv,
# deriv2,
# evalSingle,
# derivSingle,
# deriv2Single,
# Geometry,
# basis,
# coefs,
# normal,
# closest,
# invertPoints,
# MultiPatch,
# addPatch!,
# patch,
# computeTopology!,
# MultiBasis

########################################################################
# gsBoundaryConditions
########################################################################

# @enum bcType begin
#     Dirichlet = 0
#     Neumann = 1
# end

# @enum boxSide begin
#     None = 0
#     West = 1
#     East = 2
#     South = 3
#     North = 4
# end

"""
Makes a BoundaryConditions
"""
mutable struct BoundaryConditions
    ptr::Ptr{gsCBoundaryConditions}

    """
    Makes a Gismo BoundaryConditions from a pointer to a G+Smo basis.

    # Arguments
    - `bc::Ptr{gsCBoundaryConditions}`: pointer to a G+Smo bc
    - `delete::Bool=true`: if true, julia will delete the pointer


    """
    function BoundaryConditions(bc::Ptr{gsCBoundaryConditions}, delete::Bool = true)
        b = new(bc)
        if (delete)
            finalizer(destroy!, b)
        end
        return b
    end

    function BoundaryConditions()
        bc = ccall((:gsBoundaryConditions_create, libgismo), Ptr{gsCBoundaryConditions}, ())
        return BoundaryConditions(bc)
    end

    """
    Deletes a Gismo BoundaryConditions

    # Arguments
    - `b::BoundaryConditions`: a Gismo BoundaryConditions

    """
    function destroy!(bc::BoundaryConditions)
        ccall((:gsBoundaryConditions_delete, libgismo),
            Cvoid, (Ptr{gsCBoundaryConditions},), bc.ptr)
    end
end

function Base.show(io::IO, obj::BoundaryConditions)
    ccall((:gsBoundaryConditions_print, libgismo),
        Cvoid, (Ptr{gsCBoundaryConditions},), obj.ptr)
end

function addCondition!(
        bc::BoundaryConditions; patch::Int, side::Int, type::Int, fun::FunctionExpr,
        unknown::Int = 0, parametric::Bool = false, component::Int = -1)
    ccall((:gsBoundaryConditions_addCondition, libgismo),
        Cvoid,
        (Ptr{gsCBoundaryConditions}, Cint, Cint, Cint,
            Ptr{gsCFunctionExpr}, Cint, Cint, Cint),
        bc.ptr,
        patch,
        side,
        type,
        fun.ptr,
        unknown,
        parametric,
        component)
end

function addCornerValue!(bc::BoundaryConditions, patch::Int, corner::Int,
        value::Real, unknown::Int, component::Int)
    ccall((:gsBoundaryConditions_addCornerValue, libgismo), Cvoid,
        (Ptr{gsCBoundaryConditions}, Cint, Cint, Cdouble, Cint, Cint),
        bc.ptr, patch, corner, value, unknown, component)
end

function setGeoMap!(bc::BoundaryConditions, geometry::MultiPatch)
    ccall((:gsBoundaryConditions_setGeoMap, libgismo), Cvoid,
        (Ptr{gsCBoundaryConditions}, Ptr{gsCMultiPatch}), bc.ptr, geometry.ptr)
end
