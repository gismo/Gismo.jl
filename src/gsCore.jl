export
       Basis,
       show,
       destroy!,
       domainDim,
       targetDim,
       component,
       degree,
       numElements,
       size,
       degreeElevate!,
       uniformRefine!,
       refineElements!,
       refine!,
       getElements,
       boundary,
       boundaryOffset,
       actives,
       compute,
       val,
       deriv,
       deriv2,
       Geometry,
       basis,
       coefs,
       setCoefs!,
       normal,
       closest,
       invertPoints,
       MultiPatch,
       addPatch!,
       patch,
       computeTopology!,
       embed!,
       MultiBasis,
       FunctionExpr

########################################################################
# gsBasis
########################################################################
"""
Makes a Gismo Basis
"""
mutable struct Basis
    ptr::Ptr{gsCBasis}

    """
    Makes a Gismo Basis from a pointer to a G+Smo basis.

    # Arguments
    - `basis::Ptr{gsCBasis}`: pointer to a G+Smo basis
    - `delete::Bool=true`: if true, julia will delete the pointer


    """
    function Basis(basis::Ptr{gsCBasis}, delete::Bool = true)
        b = new(basis)
        if (delete)
            finalizer(destroy!, b)
        end
        return b
    end

    """
    Makes a Gismo Basis from a file.

    # Arguments
    - `filename::String`: the name of the file

    """
    function Basis(filename::String)
        b = new(ccall((:gsCReadFile, libgismo), Ptr{gsCBasis}, (Cstring,), filename))
        finalizer(destroy!, b)
        return b
    end

    """
    Deletes a Gismo Basis

    # Arguments
    - `b::Basis`: a Gismo Basis

    """
    function destroy!(b::Basis)
        ccall((:gsFunctionSet_delete, libgismo), Cvoid, (Ptr{gsCFunctionSet},), b.ptr)
    end
end

"""
Returns the domain dimension of a basis

# Arguments
- `object::Basis`: a Gismo Basis

"""
function domainDim(object::Basis)::Int
    return ccall(
        (:gsFunctionSet_domainDim, libgismo), Cint, (Ptr{gsCFunctionSet},), object.ptr)
end

"""
Returns the target dimension of a basis

# Arguments
- `object::Basis`: a Gismo Basis

"""
function targetDim(object::Basis)::Int
    return ccall(
        (:gsFunctionSet_targetDim, libgismo), Cint, (Ptr{gsCFunctionSet},), object.ptr)
end

function Base.show(io::IO, obj::Basis)
    ccall((:gsFunctionSet_print, libgismo), Cvoid, (Ptr{gsCFunctionSet},), obj.ptr)
end

"""
Returns the component of a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `i::Int`: the index of the component

"""
function component(obj::Basis, i::Int)::Basis
    b = ccall(
        (:gsBasis_component, libgismo), Ptr{gsCBasis}, (Ptr{gsCBasis}, Cint), obj.ptr, i)
    return Basis(b)
end

"""
Returns the degree of a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `i::Int`: the index of the component

"""
function degree(obj::Basis, i::Int)::Int
    return ccall((:gsBasis_degree, libgismo), Cint, (Ptr{gsCBasis}, Cint), obj.ptr, i)
end

"""
Returns the number of elements of a basis

# Arguments
- `obj::Basis`: a Gismo Basis

"""
function numElements(obj::Basis)::Int
    return ccall((:gsBasis_numElements, libgismo), Cint, (Ptr{gsCBasis},), obj.ptr)
end

"""
Returns the size of a basis

# Arguments
- `obj::Basis`: a Gismo Basis

"""
function Base.size(obj::Basis)::Int
    return ccall((:gsBasis_size, libgismo), Cint, (Ptr{gsCBasis},), obj.ptr)
end

"""
Elevates the degree of a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `numElevate::Int=Int(1)`: the number of degrees to elevate
- `dir::Int=Int(-1)`: the direction of the elevation (-1: all, 0: x, 1: y, 2: z)

"""
function degreeElevate!(obj::Basis, numElevate::Int = Int(1), dir::Int = Int(-1))::Nothing
    ccall((:gsBasis_degreeElevate, libgismo), Cvoid,
        (Ptr{gsCBasis}, Cint, Cint), obj.ptr, numElevate, dir)
end

"""
Refines a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `numKnots::Int=Int(1)`: the number of knots to add
- `mul::Int=Int(1)`: the multiplicity of the knots
- `dir::Int=Int(-1)`: the direction of the refinement

"""
function uniformRefine!(
        obj::Basis, numKnots::Int = Int(1), mul::Int = Int(1), dir::Int = Int(-1))::Nothing
    ccall((:gsBasis_uniformRefine, libgismo), Cvoid,
        (Ptr{gsCBasis}, Cint, Cint, Cint), obj.ptr, numKnots, mul, dir)
end

"""
Refines a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `boxes::Vector{Cint}`: the boxes to refine (in index format)

"""
function refineElements!(obj::Basis, boxes::Vector{Cint})::Nothing
    @assert mod(length(boxes), 2*domainDim(obj)+1)==0 "Boxes should have size 2*domainDim+1"
    ccall((:gsBasis_refineElements, libgismo), Cvoid,
        (Ptr{gsCBasis}, Ptr{Cint}, Cint),
        obj.ptr, boxes, length(boxes))
end

"""
Refines a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `boxes::Matrix{Cdouble}`: the boxes to refine (first column is the lower bound, second column is the upper bound)
- `refExt::Int=Int(0)`: the refinement extension

"""
function refine!(obj::Basis, boxes::Matrix{Cdouble}, refExt::Int = Int(0))::Nothing
    @assert Base.size(boxes, 1)==domainDim(obj) "The boxes should have the same number of rows as the domain dimension"
    @assert Base.size(boxes, 2)==2 "The boxes should have two columns"
    bb = EigenMatrix(Base.size(boxes, 1), Base.size(boxes, 2), pointer(boxes))
    ccall((:gsBasis_refine, libgismo), Cvoid,
        (Ptr{gsCBasis}, Ptr{gsCMatrix}, Cint),
        obj.ptr, bb.ptr, refExt)
end

"""
Gets the elements of the basis, as a matrix of size (domainDim x 2*numElements), with every two columns representing the lower and upper bounds of the box

# Arguments
- `obj::Basis`: a Gismo Basis
- `side::Int=0`: the side of the basis (0: none, 1: west, 2: east, 3: south, 4: north)

"""
function getElements(obj::Basis, side::Int = 0)::EigenMatrix
    result = EigenMatrix()
    if (side==0)
        ccall((:gsBasis_elements_into, libgismo), Cvoid,
            (Ptr{gsCBasis}, Ptr{gsCMatrix}),
            obj.ptr, result.ptr)
    else
        ccall((:gsBasis_elementsBdr_into, libgismo), Cvoid,
            (Cint, Ptr{gsCBasis}, Ptr{gsCMatrix}),
            side, obj.ptr, result.ptr)
    end
    # Removed redundant ccall to gsBasis_elements_into
    return result;
end

"""
Returns the boundary degrees of freedom of a basis on a side

# Arguments
- `obj::Basis`: a Gismo Basis
- `side::Int`: the side of the basis (0: none, 1: west, 2: east, 3: south, 4: north)
"""
function boundary(obj::Basis, side::Int)::EigenMatrixInt
    @assert side <= 2*domainDim(obj)+1 "Side should be less than 2*domainDim+1"
    result = EigenMatrixInt()
    ccall((:gsBasis_boundary_into, libgismo), Cvoid,
        (Ptr{gsCBasis}, Cint, Ptr{gsCMatrixInt}),
        obj.ptr, side, result.ptr)
    return result;
end

"""
Returns the boundary offset of a basis on a side

# Arguments
- `obj::Basis`: a Gismo Basis
- `side::Int`: the side of the basis (0: none, 1: west, 2: east, 3: south, 4: north)
- `offset::Int`: the offset of the boundary

"""
function boundaryOffset(obj::Basis, side::Int, offset::Int)::EigenMatrixInt
    @assert side <= 2*domainDim(obj)+1 "Side should be less than 2*domainDim+1"
    result = EigenMatrixInt()
    ccall((:gsBasis_boundaryOffset_into, libgismo), Cvoid,
        (Ptr{gsCBasis}, Cint, Cint, Ptr{gsCMatrixInt}),
        obj.ptr, side, offset, result.ptr)
    return result;
end

"""
Returns the actives of a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `u::Matrix{Cdouble}`: a matrix of points

"""
function actives(obj::Basis, u::Matrix{Cdouble})::EigenMatrixInt
    @assert Base.size(u, 1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u, 1), Base.size(u, 2), pointer(u))
    result = EigenMatrixInt()
    ccall((:gsBasis_active_into, libgismo), Cvoid,
        (Ptr{gsCBasis}, Ptr{gsCMatrix}, Ptr{gsCMatrixInt}),
        obj.ptr, uu.ptr, result.ptr)
    return result;
end

"""
Computes and returns the values, derivatives and second derivatives of a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `u::Matrix{Cdouble}`: a matrix of points
- `n::Int`: the number of derivatives to compute
"""
function compute(obj::Basis, u::Matrix{Cdouble}, n::Int)::Array{EigenMatrix}
    @assert n <= 2 "n should be less than or equal to 2"
    @assert Base.size(u, 1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u, 1), Base.size(u, 2), pointer(u))
    if (n==0) # values only
        result = EigenMatrix()
        ccall((:gsFunctionSet_eval_into, libgismo), Cvoid,
            (Ptr{gsCBasis}, Ptr{gsCMatrix}, Ptr{gsCMatrix}),
            obj.ptr, uu.ptr, result.ptr)
        return Array{EigenMatrix}([result]);
    elseif (n==1) # values and derivatives
        val = EigenMatrix()
        der = EigenMatrix()
        ccall((:gsFunctionSet_evalAllDers1_into, libgismo), Cvoid,
            (Ptr{gsCBasis}, Ptr{gsCMatrix}, Ptr{gsCMatrix}, Ptr{gsCMatrix}),
            obj.ptr, uu.ptr, val.ptr, der.ptr)
        return Array{EigenMatrix}([val, der]);
    elseif (n==2) # values, derivatives and second derivatives
        val = EigenMatrix()
        der = EigenMatrix()
        der2 = EigenMatrix()
        ccall((:gsFunctionSet_evalAllDers2_into, libgismo), Cvoid,
            (Ptr{gsCBasis}, Ptr{gsCMatrix}, Ptr{gsCMatrix}, Ptr{gsCMatrix}, Ptr{gsCMatrix}),
            obj.ptr, uu.ptr, val.ptr, der.ptr, der2.ptr)
        return Array{EigenMatrix}([val, der, der2]);
    end
end

"""
Returns the evaluation of a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `u::Matrix{Cdouble}`: a matrix of points

"""
function val(obj::Basis, u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u, 1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u, 1), Base.size(u, 2), pointer(u))
    result = EigenMatrix()
    ccall((:gsFunctionSet_eval_into, libgismo), Cvoid,
        (Ptr{gsCBasis}, Ptr{gsCMatrix}, Ptr{gsCMatrix}),
        obj.ptr, uu.ptr, result.ptr)
    return result;
end

"""
Returns the derivative of a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `u::Matrix{Cdouble}`: a matrix of points

"""
function deriv(obj::Basis, u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u, 1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u, 1), Base.size(u, 2), pointer(u))
    result = EigenMatrix()
    ccall((:gsFunctionSet_deriv_into, libgismo), Cvoid,
        (Ptr{gsCBasis}, Ptr{gsCMatrix}, Ptr{gsCMatrix}),
        obj.ptr, uu.ptr, result.ptr)
    return result;
end
"""
Returns the second derivative of a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `u::Matrix{Cdouble}`: a matrix of points

"""
function deriv2(obj::Basis, u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u, 1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u, 1), Base.size(u, 2), pointer(u))
    result = EigenMatrix()
    ccall((:gsFunctionSet_deriv2_into, libgismo), Cvoid,
        (Ptr{gsCBasis}, Ptr{gsCMatrix}, Ptr{gsCMatrix}),
        obj.ptr, uu.ptr, result.ptr)
    return result;
end

"""
Returns the evaluation of a single basis function

# Arguments
- `obj::Basis`: a Gismo Basis
- `i::Int`: the index of the basis function
- `u::Matrix{Cdouble}`: a matrix of points

"""
function val(obj::Basis, i::Int, u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u, 1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u, 1), Base.size(u, 2), pointer(u))
    result = EigenMatrix()
    ccall((:gsBasis_evalSingle_into, libgismo), Cvoid,
        (Ptr{gsCBasis}, Cint, Ptr{gsCMatrix}, Ptr{gsCMatrix}),
        obj.ptr, i, uu.ptr, result.ptr)
    return result;
end

"""
Returns the derivative of a single basis function

# Arguments
- `obj::Basis`: a Gismo Basis
- `i::Int`: the index of the basis function
- `u::Matrix{Cdouble}`: a matrix of points

"""
function deriv(obj::Basis, i::Int, u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u, 1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u, 1), Base.size(u, 2), pointer(u))
    result = EigenMatrix()
    ccall((:gsBasis_derivSingle_into, libgismo), Cvoid,
        (Ptr{gsCBasis}, Cint, Ptr{gsCMatrix}, Ptr{gsCMatrix}),
        obj.ptr, i, uu.ptr, result.ptr)
    return result;
end

"""
Returns the second derivative of a single basis function

# Arguments
- `obj::Basis`: a Gismo Basis
- `i::Int`: the index of the basis function
- `u::Matrix{Cdouble}`: a matrix of points

"""
function deriv2(obj::Basis, i::Int, u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u, 1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u, 1), Base.size(u, 2), pointer(u))
    result = EigenMatrix()
    ccall((:gsBasis_deriv2Single_into, libgismo), Cvoid,
        (Ptr{gsCBasis}, Cint, Ptr{gsCMatrix}, Ptr{gsCMatrix}),
        obj.ptr, i, uu.ptr, result.ptr)
    return result;
end

########################################################################
# gsGeometry
########################################################################

"""
Makes a Gismo Geometry
"""
mutable struct Geometry
    ptr::Ptr{gsCGeometry}

    # delete==true: julia will delete the pointer
    """
    Makes a Gismo Geometry from a pointer to a G+Smo geometry.

    # Arguments
    - `geom::Ptr{gsCGeometry}`: pointer to a G+Smo geometry
    - `delete::Bool=true`: if true, julia will delete the pointer


    """
    function Geometry(geom::Ptr{gsCGeometry}, delete::Bool = true)
        g = new(geom)

        if (delete)
            finalizer(destroy!, g)
        end
        return g
    end

    function Geometry(filename::String)
        g = new(ccall((:gsCReadFile, libgismo), Ptr{gsCGeometry}, (Cstring,), filename))
        finalizer(destroy!, g)
        return g
    end

    function destroy!(g::Geometry)
        ccall((:gsFunctionSet_delete, libgismo), Cvoid, (Ptr{gsCFunctionSet},), g.ptr)
    end
end

"""
Return the domain dimension of a geometry

# Arguments
- `object::Geometry`: a Gismo Geometry

"""
function domainDim(object::Geometry)::Int
    return ccall(
        (:gsFunctionSet_domainDim, libgismo), Cint, (Ptr{gsCFunctionSet},), object.ptr)
end

"""
Returns the target dimension of a geometry

# Arguments
- `object::Geometry`: a Gismo Geometry

"""
function targetDim(object::Geometry)::Int
    return ccall(
        (:gsFunctionSet_targetDim, libgismo), Cint, (Ptr{gsCFunctionSet},), object.ptr)
end

function Base.show(io::IO, obj::Geometry)
    ccall((:gsFunctionSet_print, libgismo), Cvoid, (Ptr{gsCFunctionSet},), obj.ptr)
end

"""
Returns the basis of a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry

"""
function basis(obj::Geometry)::Basis
    b = ccall((:gsBasis_basis, libgismo), Ptr{gsCBasis}, (Ptr{gsCGeometry},), obj.ptr)
    return Basis(b)
end

"""
Returns the coefficients of a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry

"""
function coefs(obj::Geometry)::EigenMatrix
    result = EigenMatrix()
    ccall((:gsGeometry_coefs_into, libgismo), Cvoid,
        (Ptr{gsCGeometry}, Ptr{gsCMatrix}), obj.ptr, result.ptr)
    return result;
end

"""
Sets the coefficients of a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry
- `coefs::EigenMatrix`: the coefficients

"""
function setCoefs!(obj::Geometry, coefs::Matrix{Cdouble})::Nothing
    @assert Base.size(coefs, 1)==size(basis(obj)) "The number of rows of the coefficients should be equal to the number of degrees of freedom"
    cc = EigenMatrix(Base.size(coefs, 1), Base.size(coefs, 2), pointer(coefs))
    ccall((:gsGeometry_setCoefs, libgismo), Cvoid,
        (Ptr{gsCGeometry}, Ptr{gsCMatrix}), obj.ptr, cc.ptr)
end

"""
Uniformly refines a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry
- `numKnots::Int=Int(1)`: the number of knots to add
- `mul::Int=Int(1)`: the multiplicity of the knots
- `dir::Int=Int(-1)`: the direction of the refinement (-1: all, 0: x, 1: y, 2: z)

"""
function uniformRefine!(obj::Geometry, numKnots::Int = Int(1),
        mul::Int = Int(1), dir::Int = Int(-1))::Nothing
    ccall((:gsGeometry_uniformRefine, libgismo), Cvoid,
        (Ptr{gsCGeometry}, Cint, Cint, Cint), obj.ptr, numKnots, mul, dir)
end

"""
Elevates the degree of a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry
- `numElevate::Int=Int(1)`: the number of degrees to elevate
- `dir::Int=Int(-1)`: the direction of the elevation (-1: all, 0: x, 1: y, 2: z)

"""
function degreeElevate!(
        obj::Geometry, numElevate::Int = Int(1), dir::Int = Int(-1))::Nothing
    ccall((:gsGeometry_degreeElevate, libgismo), Cvoid,
        (Ptr{gsCGeometry}, Cint, Cint), obj.ptr, numElevate, dir)
end

"""
Computes and returns the values, derivatives and second derivatives of a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry
- `u::Matrix{Cdouble}`: a matrix of points
- `n::Int`: the number of derivatives to compute
"""
function compute(obj::Geometry, u::Matrix{Cdouble}, n::Int)::Array{EigenMatrix}
    @assert n <= 2 "n should be less than or equal to 2"
    @assert Base.size(u, 1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u, 1), Base.size(u, 2), pointer(u))
    if (n==0) # values only
        result = EigenMatrix()
        ccall((:gsFunctionSet_eval_into, libgismo), Cvoid,
            (Ptr{gsCGeometry}, Ptr{gsCMatrix}, Ptr{gsCMatrix}),
            obj.ptr, uu.ptr, result.ptr)
        return Array{EigenMatrix}([result]);
    elseif (n==1) # values and derivatives
        val = EigenMatrix()
        der = EigenMatrix()
        ccall((:gsFunctionSet_evalAllDers1_into, libgismo), Cvoid,
            (Ptr{gsCGeometry}, Ptr{gsCMatrix}, Ptr{gsCMatrix}, Ptr{gsCMatrix}),
            obj.ptr, uu.ptr, val.ptr, der.ptr)
        return Array{EigenMatrix}([val, der]);
    elseif (n==2) # values, derivatives and second derivatives
        val = EigenMatrix()
        der = EigenMatrix()
        der2 = EigenMatrix()
        ccall((:gsFunctionSet_evalAllDers2_into, libgismo), Cvoid,
            (Ptr{gsCGeometry}, Ptr{gsCMatrix},
                Ptr{gsCMatrix}, Ptr{gsCMatrix}, Ptr{gsCMatrix}),
            obj.ptr, uu.ptr, val.ptr, der.ptr, der2.ptr)
        return Array{EigenMatrix}([val, der, der2]);
    end
end

"""
Returns the evaluation of a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry
- `u::Matrix{Cdouble}`: a matrix of points

"""
function val(obj::Geometry, u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u, 1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u, 1), Base.size(u, 2), pointer(u))
    result = EigenMatrix()
    ccall((:gsFunctionSet_eval_into, libgismo), Cvoid,
        (Ptr{gsCGeometry}, Ptr{gsCMatrix}, Ptr{gsCMatrix}),
        obj.ptr, uu.ptr, result.ptr)
    return result;
end

"""
Returns the derivative of a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry
- `u::Matrix{Cdouble}`: a matrix of points

"""
function deriv(obj::Geometry, u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u, 1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u, 1), Base.size(u, 2), pointer(u))
    result = EigenMatrix()
    ccall((:gsFunctionSet_deriv_into, libgismo), Cvoid,
        (Ptr{gsCGeometry}, Ptr{gsCMatrix}, Ptr{gsCMatrix}),
        obj.ptr, uu.ptr, result.ptr)
    return result;
end

"""
Returns the second derivative of a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry
- `u::Matrix{Cdouble}`: a matrix of points

"""
function deriv2(obj::Geometry, u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u, 1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u, 1), Base.size(u, 2), pointer(u))
    result = EigenMatrix()
    ccall((:gsFunctionSet_deriv2_into, libgismo), Cvoid,
        (Ptr{gsCGeometry}, Ptr{gsCMatrix}, Ptr{gsCMatrix}),
        obj.ptr, uu.ptr, result.ptr)
    return result;
end

"""
Returns the normal of a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry
- `u::Matrix{Cdouble}`: a matrix of points

"""
function normal(obj::Geometry, u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u, 1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u, 1), Base.size(u, 2), pointer(u))
    result = EigenMatrix()
    ccall((:gsGeometry_normal_into, libgismo), Cvoid,
        (Ptr{gsCGeometry}, Ptr{gsCMatrix}, Ptr{gsCMatrix}),
        obj.ptr, uu.ptr, result.ptr)
    return result;
end

"""
Returns the closest point of a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry
- `x::Matrix{Cdouble}`: a matrix of points
- `accuracy::Cdouble=1e-6`: the accuracy of the computation

"""
function closest(obj::Geometry, x::Matrix{Cdouble},
        accuracy::Cdouble = 1e-6)::Tuple{Cdouble, EigenMatrix}
    xx = EigenMatrix(Base.size(x, 1), Base.size(x, 2), pointer(x))
    result = EigenMatrix()
    dist = ccall((:gsGeometry_closestPointTo, libgismo), Cdouble,
        (Ptr{gsCGeometry}, Ptr{gsCMatrix}, Ptr{gsCMatrix}, Cdouble),
        obj.ptr, xx.ptr, result.ptr, accuracy)
    return dist, result;
end

"""
Inverts a set of points

# Arguments
- `obj::Geometry`: a Gismo Geometry
- `x::Matrix{Cdouble}`: a matrix of points
- `accuracy::Cdouble=1e-6`: the accuracy of the computation

"""
function invertPoints(
        obj::Geometry, x::Matrix{Cdouble}, accuracy::Cdouble = 1e-6)::EigenMatrix
    xx = EigenMatrix(Base.size(x, 1), 1, pointer(x))
    result = EigenMatrix()
    ccall((:gsGeometry_invertPoints, libgismo), Cvoid,
        (Ptr{gsCGeometry}, Ptr{gsCMatrix}, Ptr{gsCMatrix}, Cdouble),
        obj.ptr, xx.ptr, result.ptr, accuracy)
    return result;
end

########################################################################
# gsMultiPatch
########################################################################

"""
Makes a Gismo MultiPatch
"""
mutable struct MultiPatch
    ptr::Ptr{gsCMultiPatch}

    # function MultiPatch(filename::String)
    #     g = new(ccall((:gsCReadFile,libgismo),Ptr{gsCMultiPatch},(Cstring,),filename) )
    #     finalizer(destroy!, g)
    #     return g
    # end

    function MultiPatch(multipatch::Ptr{gsCMultiPatch}, delete::Bool = true)
        b = new(multipatch)
        if (delete)
            finalizer(destroy!, b)
        end
        return b
    end

    function MultiPatch()
        m = new(ccall((:gsMultiPatch_create, libgismo), Ptr{gsCMultiPatch}, ()))
        finalizer(destroy!, m)
        return m
    end

    function MultiPatch(patch::Geometry)
        m = new(ccall((:gsMultiPatch_create_geometry, libgismo),
            Ptr{gsCMultiPatch}, ((Ptr{gsCGeometry},)), patch.ptr))
        finalizer(destroy!, m)
        return m
    end

    function destroy!(m::MultiPatch)
        ccall((:gsFunctionSet_delete, libgismo), Cvoid, (Ptr{gsCFunctionSet},), m.ptr)
    end
end

"""
Adds a patch to a MultiPatch

# Arguments
- `obj::MultiPatch`: a Gismo MultiPatch
- `geom::Geometry`: a Gismo Geometry

"""
function domainDim(object::MultiPatch)::Int
    return ccall(
        (:gsFunctionSet_domainDim, libgismo), Cint, (Ptr{gsCFunctionSet},), object.ptr)
end

"""
Returns the target dimension of a MultiPatch

# Arguments
- `object::MultiPatch`: a Gismo MultiPatch

"""
function targetDim(object::MultiPatch)::Int
    return ccall(
        (:gsFunctionSet_targetDim, libgismo), Cint, (Ptr{gsCFunctionSet},), object.ptr)
end

function Base.show(io::IO, obj::MultiPatch)
    ccall((:gsFunctionSet_print, libgismo), Cvoid, (Ptr{gsCFunctionSet},), obj.ptr)
end

"""
Returns the basis of a MultiPatch

# Arguments
- `obj::MultiPatch`: a Gismo MultiPatch

"""
function addPatch!(obj::MultiPatch, geom::Geometry)::Nothing
    ccall((:gsMultiPatch_addPatch, libgismo), Cvoid,
        (Ptr{gsCMultiPatch}, Ptr{gsCGeometry}), obj.ptr, geom.ptr)
end

"""
Returns the coefficients of a MultiPatch

# Arguments
- `obj::MultiPatch`: a Gismo MultiPatch

"""
function basis(obj::MultiPatch, i::Int)::Basis
    b = ccall((:gsMultiPatch_basis, libgismo), Ptr{gsCBasis},
        (Ptr{gsCFunctionSet}, Cint), obj.ptr, i)
    return Basis(b, false)
end

"""
Returns the coefficients of a MultiPatch

# Arguments
- `obj::MultiPatch`: a Gismo MultiPatch
- `i::Int`: the index of the patch

"""
function patch(obj::MultiPatch, i::Int = 0)::Geometry
    g = ccall((:gsMultiPatch_patch, libgismo), Ptr{gsCGeometry},
        (Ptr{gsCMultiPatch}, Cint), obj.ptr, i)
    return Geometry(g, false)
end

"""
Computes the topology of a MultiPatch

# Arguments
- `obj::MultiPatch`: a Gismo MultiPatch

"""
function computeTopology!(obj::MultiPatch)::Nothing
    ccall((:gsMultiPatch_computeTopology, libgismo), Cvoid, (Ptr{gsCMultiPatch},), obj.ptr)
end

"""
Embeds a MultiPatch into a given dimension

# Arguments
- `obj::MultiPatch`: a Gismo MultiPatch
- `dim::Cint`: the dimension to embed into (2: 2D, 3: 3D)
"""
function embed!(obj::MultiPatch, dim::Int)::Nothing
    ccall((:gsMultiPatch_embed, libgismo), Cvoid, (Ptr{gsCMultiPatch}, Int), obj.ptr, dim)
end

"""
Uniformly refines a MultiPatch

# Arguments
- `obj::MultiPatch`: a Gismo MultiPatch
- `numKnots::Int=Int(1)`: the number of knots to add
- `mul::Int=Int(1)`: the multiplicity of the knots
- `dir::Int=Int(-1)`: the direction of the refinement (-1: all, 0: x, 1: y, 2: z)
"""
function uniformRefine!(obj::MultiPatch, numKnots::Int = Int(1),
        mul::Int = Int(1), dir::Int = Int(-1))::Nothing
    ccall((:gsMultiPatch_uniformRefine, libgismo), Cvoid,
        (Ptr{gsCMultiPatch}, Cint, Cint, Cint), obj.ptr, numKnots, mul, dir)
end

"""
Elevates the degree of a MultiPatch

# Arguments
- `obj::MultiPatch`: a Gismo MultiPatch
- `numElevate::Int=Int(1)`: the number of degrees to elevate
- `dir::Int=Int(-1)`: the direction of the elevation (-1: all, 0: x, 1: y, 2: z)
"""
function degreeElevate!(
        obj::MultiPatch, numElevate::Int = Int(1), dir::Int = Int(-1))::Nothing
    ccall((:gsMultiPatch_degreeElevate, libgismo), Cvoid,
        (Ptr{gsCMultiPatch}, Cint, Cint), obj.ptr, numElevate, dir)
end

"""
Returns the size of a MultiPatch (number of patches)

# Arguments
- `obj::MultiPatch`: a Gismo MultiPatch

"""
function Base.size(obj::MultiPatch)::Int
    return ccall((:gsFunctionSet_nPieces, libgismo), Cint, (Ptr{gsCFunctionSet},), obj.ptr)
end

########################################################################
# gsMultiBasis
########################################################################

"""
Makes a Gismo MultiBasis
"""
mutable struct MultiBasis
    ptr::Ptr{gsCMultiBasis}

    # function MultiBasis(filename::String)
    #     g = new(ccall((:gsCReadFile,libgismo),Ptr{gsCMultiBasis},(Cstring,),filename) )
    #     finalizer(destroy!, g)
    #     return g
    # end

    function MultiBasis()
        m = new(ccall((:gsMultiBasis_create, libgismo), Ptr{gsCMultiBasis}, ()))
        finalizer(destroy!, m)
        return m
    end

    function MultiBasis(multiPatch::MultiPatch)
        m = new(ccall((:gsMultiBasis_create_patches, libgismo), Ptr{gsCMultiBasis},
            ((Ptr{gsCMultiPatch},)), multiPatch.ptr))
        finalizer(destroy!, m)
        return m
    end

    function destroy!(m::MultiBasis)
        ccall((:gsFunctionSet_delete, libgismo), Cvoid, (Ptr{gsCFunctionSet},), m.ptr)
    end
end

"""
Returns the basus of a MultiBasis

# Arguments
- `obj::MultiBasis`: a Gismo MultiBasis
- `i::Int`: the index of the basis

"""
function basis(obj::MultiBasis, i::Int)::Basis
    b = ccall((:gsMultiBasis_basis, libgismo), Ptr{gsCBasis},
        (Ptr{gsCFunctionSet}, Cint), obj.ptr, i)
    return Basis(b, false)
end

########################################################################
# gsFunctionExpr
########################################################################

"""
Makes a Gismo FunctionExpr
"""
mutable struct FunctionExpr
    ptr::Ptr{gsCFunctionExpr}

    function FunctionExpr(domainDim::Int, funs::Vararg{String})
        targetDim = Base.length(funs)
        if (targetDim==1)
            f = new(ccall((:gsFunctionExpr1_create, libgismo), Ptr{gsCFunctionExpr},
                (Cstring, Cint), funs[1], domainDim))
        elseif (targetDim==2)
            f = new(ccall((:gsFunctionExpr2_create, libgismo), Ptr{gsCFunctionExpr},
                (Cstring, Cstring, Cint), funs[1], funs[2], domainDim))
        elseif (targetDim==3)
            f = new(ccall((:gsFunctionExpr3_create, libgismo), Ptr{gsCFunctionExpr},
                (Cstring, Cstring, Cstring, Cint), funs[1], funs[2], funs[3], domainDim))
        elseif (targetDim==4)
            f = new(ccall((:gsFunctionExpr4_create, libgismo), Ptr{gsCFunctionExpr},
                (Cstring, Cstring, Cstring, Cstring, Cint),
                funs[1], funs[2], funs[3], funs[4], domainDim))
        elseif (targetDim==9)
            f = new(ccall((:gsFunctionExpr9_create, libgismo),
                Ptr{gsCFunctionExpr},
                (Cstring, Cstring, Cstring, Cstring, Cstring,
                    Cstring, Cstring, Cstring, Cstring, Cint),
                funs[1],
                funs[2],
                funs[3],
                funs[4],
                funs[5],
                funs[6],
                funs[7],
                funs[8],
                funs[9],
                domainDim))
        else
            error("Target dimension must be 1, 2, 4 or 9")
        end
        finalizer(destroy!, f)
        return f
    end

    function destroy!(f::FunctionExpr)
        ccall((:gsFunctionSet_delete, libgismo), Cvoid, (Ptr{gsCFunctionExpr},), f.ptr)
    end
end

function Base.show(io::IO, obj::FunctionExpr)
    ccall((:gsFunctionSet_print, libgismo), Cvoid, (Ptr{gsCFunctionExpr},), obj.ptr)
end
