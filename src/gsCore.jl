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
    uniformRefine!,
    refineElements!,
    refine!,
    actives,
    val,
    deriv,
    deriv2,
    evalSingle,
    derivSingle,
    deriv2Single,
    Geometry,
    basis,
    coefs,
    normal,
    closest,
    invertPoints,
    MultiPatch,
    addPatch!,
    patch,
    computeTopology!,
    MultiBasis

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
    function Basis(basis::Ptr{gsCBasis},delete::Bool=true)
        b = new(basis)
        if (delete)
            finalizer(destroy!,b)
        end
        return b
    end

    """
    Makes a Gismo Basis from a file.

    # Arguments
    - `filename::String`: the name of the file

    """
    function Basis(filename::String)
        b = new(ccall((:gsCReadFile,libgismo),Ptr{gsCBasis},(Cstring,),filename) )
        finalizer(destroy!, b)
        return b
    end

    """
    Deletes a Gismo Basis

    # Arguments
    - `b::Basis`: a Gismo Basis

    """
    function destroy!(b::Basis)
        ccall((:gsFunctionSet_delete,libgismo),Cvoid,(Ptr{gsCFunctionSet},),b.ptr)
    end
end

"""
Returns the domain dimension of a basis

# Arguments
- `object::Basis`: a Gismo Basis

"""
function domainDim(object::Basis)::Int
    return ccall((:gsFunctionSet_domainDim,libgismo),Cint,(Ptr{gsCFunctionSet},),object.ptr)
end

"""
Returns the target dimension of a basis

# Arguments
- `object::Basis`: a Gismo Basis

"""
function targetDim(object::Basis)::Int
    return ccall((:gsFunctionSet_targetDim,libgismo),Cint,(Ptr{gsCFunctionSet},),object.ptr)
end

Base.show(io::IO, obj::Basis) = ccall((:gsFunctionSet_print,libgismo),Cvoid,(Ptr{gsCFunctionSet},),obj.ptr)

"""
Returns the component of a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `i::Int`: the index of the component

"""
function component(obj::Basis,i::Int)::Basis
    b = ccall((:gsBasis_component,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},Cint),obj.ptr,i)
    return Basis(b)
end

"""
Returns the degree of a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `i::Int`: the index of the component

"""
function degree(obj::Basis,i::Int)::Int
    return ccall((:gsBasis_degree,libgismo),Cint,(Ptr{gsCBasis},Cint),obj.ptr,i)
end

"""
Returns the number of elements of a basis

# Arguments
- `obj::Basis`: a Gismo Basis

"""
function numElements(obj::Basis)::Int
    return ccall((:gsBasis_numElements,libgismo),Cint,(Ptr{gsCBasis},),obj.ptr)
end

"""
Returns the size of a basis

# Arguments
- `obj::Basis`: a Gismo Basis

"""
function Base.size(obj::Basis)::Int
    return ccall((:gsBasis_size,libgismo),Cint,(Ptr{gsCBasis},),obj.ptr)
end

"""
Refines a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `numKnots::Int=Int(1)`: the number of knots to add
- `mul::Int=Int(1)`: the multiplicity of the knots
- `dir::Int=Int(-1)`: the direction of the refinement

"""
function uniformRefine!(obj::Basis,numKnots::Int=Int(1),mul::Int=Int(1),dir::Int=Int(-1))::Nothing
    ccall((:gsBasis_uniformRefine,libgismo),Cvoid,
            (Ptr{gsCBasis},Cint,Cint,Cint),obj.ptr,numKnots,mul,dir)
end

"""
Refines a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `boxes::Vector{Cint}`: the boxes to refine (in index format)

"""
function refineElements!(obj::Basis,boxes::Vector{Cint})::Nothing
    @assert mod(length(boxes),2*domainDim(obj)+1)==0 "Boxes should have size 2*domainDim+1"
    ccall((:gsBasis_refineElements,libgismo),Cvoid,
            (Ptr{gsCBasis},Ptr{Cint},Cint),
            obj.ptr,boxes,length(boxes))
end

"""
Refines a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `boxes::Matrix{Cdouble}`: the boxes to refine (first column is the lower bound, second column is the upper bound)
- `refExt::Int=Int(0)`: the refinement extension

"""
function refine!(obj::Basis,boxes::Matrix{Cdouble},refExt::Int=Int(0))::Nothing
    @assert Base.size(boxes,1)==domainDim(obj) "The boxes should have the same number of rows as the domain dimension"
    @assert Base.size(boxes,2)==2 "The boxes should have two columns"
    bb = EigenMatrix(Base.size(boxes,1), Base.size(boxes,2), pointer(boxes) )
    ccall((:gsBasis_refine,libgismo),Cvoid,
            (Ptr{gsCBasis},Ptr{gsCMatrix},Cint),
            obj.ptr,bb.ptr,refExt)
end


"""
Returns the actives of a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `u::Matrix{Cdouble}`: a matrix of points

"""
function actives(obj::Basis,u::Matrix{Cdouble})::EigenMatrixInt
    @assert Base.size(u,1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u,1), Base.size(u,2), pointer(u) )
    result = EigenMatrixInt()
    ccall((:gsBasis_active_into,libgismo),Cvoid,
      (Ptr{gsCBasis},Ptr{gsCMatrix},Ptr{gsCMatrixInt},),
      obj.ptr,uu.ptr,result.ptr)
    return result;
end

"""
Returns the evaluation of a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `u::Matrix{Cdouble}`: a matrix of points

"""
function val(obj::Basis,u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u,1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u,1), Base.size(u,2), pointer(u) )
    result = EigenMatrix()
    ccall((:gsFunctionSet_eval_into,libgismo),Cvoid,
      (Ptr{gsCBasis},Ptr{gsCMatrix},Ptr{gsCMatrix},),
      obj.ptr,uu.ptr,result.ptr)
    return result;
end


"""
Returns the derivative of a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `u::Matrix{Cdouble}`: a matrix of points

"""
function deriv(obj::Basis,u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u,1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u,1), Base.size(u,2), pointer(u) )
    result = EigenMatrix()
    ccall((:gsFunctionSet_deriv_into,libgismo),Cvoid,
      (Ptr{gsCBasis},Ptr{gsCMatrix},Ptr{gsCMatrix},),
      obj.ptr,uu.ptr,result.ptr)
    return result;
end
"""
Returns the second derivative of a basis

# Arguments
- `obj::Basis`: a Gismo Basis
- `u::Matrix{Cdouble}`: a matrix of points

"""
function deriv2(obj::Basis,u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u,1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u,1), Base.size(u,2), pointer(u) )
    result = EigenMatrix()
    ccall((:gsFunctionSet_deriv2_into,libgismo),Cvoid,
      (Ptr{gsCBasis},Ptr{gsCMatrix},Ptr{gsCMatrix},),
      obj.ptr,uu.ptr,result.ptr)
    return result;
end

"""
Returns the evaluation of a single basis function

# Arguments
- `obj::Basis`: a Gismo Basis
- `i::Int`: the index of the basis function
- `u::Matrix{Cdouble}`: a matrix of points

"""
function val(obj::Basis,i::Int,u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u,1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u,1), Base.size(u,2), pointer(u) )
    result = EigenMatrix()
    ccall((:gsBasis_evalSingle_into,libgismo),Cvoid,
      (Ptr{gsCBasis},Cint,Ptr{gsCMatrix},Ptr{gsCMatrix},),
      obj.ptr,i,uu.ptr,result.ptr)
    return result;
end

"""
Returns the derivative of a single basis function

# Arguments
- `obj::Basis`: a Gismo Basis
- `i::Int`: the index of the basis function
- `u::Matrix{Cdouble}`: a matrix of points

"""
function deriv(obj::Basis,i::Int,u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u,1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u,1), Base.size(u,2), pointer(u) )
    result = EigenMatrix()
    ccall((:gsBasis_derivSingle_into,libgismo),Cvoid,
      (Ptr{gsCBasis},Cint,Ptr{gsCMatrix},Ptr{gsCMatrix},),
      obj.ptr,i,uu.ptr,result.ptr)
    return result;
end

"""
Returns the second derivative of a single basis function

# Arguments
- `obj::Basis`: a Gismo Basis
- `i::Int`: the index of the basis function
- `u::Matrix{Cdouble}`: a matrix of points

"""
function deriv2(obj::Basis,i::Int,u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u,1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u,1), Base.size(u,2), pointer(u) )
    result = EigenMatrix()
    ccall((:gsBasisSet_deriv2Single_into,libgismo),Cvoid,
      (Ptr{gsCBasis},Cint,Ptr{gsCMatrix},Ptr{gsCMatrix},),
      obj.ptr,i,uu.ptr,result.ptr)
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
    function Geometry(geom::Ptr{gsCGeometry},delete::Bool=true)
        g = new(geom)

        if (delete)
            finalizer(destroy!,g)
        end
        return g
    end

    function Geometry(filename::String)
        g = new(ccall((:gsCReadFile,libgismo),Ptr{gsCGeometry},(Cstring,),filename) )
        finalizer(destroy!, g)
        return g
    end

    function destroy!(g::Geometry)
        ccall((:gsFunctionSet_delete,libgismo),Cvoid,(Ptr{gsCFunctionSet},),g.ptr)
    end
end

"""
Return the domain dimension of a geometry

# Arguments
- `object::Geometry`: a Gismo Geometry

"""
function domainDim(object::Geometry)::Int
    return ccall((:gsFunctionSet_domainDim,libgismo),Cint,(Ptr{gsCFunctionSet},),object.ptr)
end

"""
Returns the target dimension of a geometry

# Arguments
- `object::Geometry`: a Gismo Geometry

"""
function targetDim(object::Geometry)::Int
    return ccall((:gsFunctionSet_targetDim,libgismo),Cint,(Ptr{gsCFunctionSet},),object.ptr)
end

Base.show(io::IO, obj::Geometry) = ccall((:gsFunctionSet_print,libgismo),Cvoid,(Ptr{gsCFunctionSet},),obj.ptr)

"""
Returns the basis of a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry

"""
function basis(obj::Geometry)::Basis
    b = ccall((:gsBasis_basis,libgismo),Ptr{gsCBasis},(Ptr{gsCGeometry},),obj.ptr)
    return Basis(b)
end

"""
Returns the coefficients of a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry

"""
function coefs(obj::Geometry)::EigenMatrix
    result = EigenMatrix()
    ccall((:gsGeometry_coefs_into,libgismo),Cvoid,(Ptr{gsCGeometry},Ptr{gsCMatrix},),obj.ptr,result.ptr)
    return result;
end

"""
Returns the evaluation of a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry
- `u::Matrix{Cdouble}`: a matrix of points

"""
function val(obj::Geometry,u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u,1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u,1), Base.size(u,2), pointer(u) )
    result = EigenMatrix()
    ccall((:gsFunctionSet_eval_into,libgismo),Cvoid,
      (Ptr{gsCGeometry},Ptr{gsCMatrix},Ptr{gsCMatrix},),
      obj.ptr,uu.ptr,result.ptr)
    return result;
end

"""
Returns the derivative of a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry
- `u::Matrix{Cdouble}`: a matrix of points

"""
function deriv(obj::Geometry,u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u,1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u,1), Base.size(u,2), pointer(u) )
    result = EigenMatrix()
    ccall((:gsFunctionSet_deriv_into,libgismo),Cvoid,
      (Ptr{gsCGeometry},Ptr{gsCMatrix},Ptr{gsCMatrix},),
      obj.ptr,uu.ptr,result.ptr)
    return result;
end

"""
Returns the second derivative of a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry
- `u::Matrix{Cdouble}`: a matrix of points

"""
function deriv2(obj::Geometry,u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u,1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u,1), Base.size(u,2), pointer(u) )
    result = EigenMatrix()
    ccall((:gsFunctionSet_deriv2_into,libgismo),Cvoid,
      (Ptr{gsCGeometry},Ptr{gsCMatrix},Ptr{gsCMatrix},),
      obj.ptr,uu.ptr,result.ptr)
    return result;
end

"""
Returns the normal of a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry
- `u::Matrix{Cdouble}`: a matrix of points

"""
function normal(obj::Geometry,u::Matrix{Cdouble})::EigenMatrix
    @assert Base.size(u,1)==domainDim(obj) "Domain dimension should be equal to the number of rows of the points"
    uu = EigenMatrix(Base.size(u,1), Base.size(u,2), pointer(u) )
    result = EigenMatrix()
    ccall((:gsGeometry_normal_into,libgismo),Cvoid,
      (Ptr{gsCGeometry},Ptr{gsCMatrix},Ptr{gsCMatrix},),
      obj.ptr,uu.ptr,result.ptr)
    return result;
end

"""
Returns the closest point of a geometry

# Arguments
- `obj::Geometry`: a Gismo Geometry
- `x::Matrix{Cdouble}`: a matrix of points
- `accuracy::Cdouble=1e-6`: the accuracy of the computation

"""
function closest(obj::Geometry,x::Matrix{Cdouble},accuracy::Cdouble=1e-6)::Tuple{Cdouble,EigenMatrix}
    xx = EigenMatrix(Base.size(x,1), Base.size(x,2), pointer(x) )
    result = EigenMatrix()
    dist = ccall((:gsGeometry_closestPointTo,libgismo),Cdouble,
      (Ptr{gsCGeometry},Ptr{gsCMatrix},Ptr{gsCMatrix},Cdouble,),
      obj.ptr,xx.ptr,result.ptr,accuracy)
    return dist,result;
end

"""
Inverts a set of points

# Arguments
- `obj::Geometry`: a Gismo Geometry
- `x::Matrix{Cdouble}`: a matrix of points
- `accuracy::Cdouble=1e-6`: the accuracy of the computation

"""
function invertPoints(obj::Geometry,x::Matrix{Cdouble},accuracy::Cdouble=1e-6)::EigenMatrix
    xx = EigenMatrix(Base.size(x,1), 1, pointer(x) )
    result = EigenMatrix()
    ccall((:gsGeometry_invertPoints,libgismo),Cvoid,
      (Ptr{gsCGeometry},Ptr{gsCMatrix},Ptr{gsCMatrix},Cdouble,),
      obj.ptr,xx.ptr,result.ptr,accuracy)
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

    function MultiPatch(multipatch::Ptr{gsCMultiPatch},delete::Bool=true)
        b = new(multipatch)
        if (delete)
            finalizer(destroy!,b)
        end
        return b
    end

    function MultiPatch()
        m = new(ccall((:gsMultiPatch_create,libgismo),Ptr{gsCMultiPatch},(),) )
        finalizer(destroy!, m)
        return m
    end

    function destroy!(m::MultiPatch)
        ccall((:gsFunctionSet_delete,libgismo),Cvoid,(Ptr{gsCFunctionSet},),m.ptr)
    end
end

"""
Adds a patch to a MultiPatch

# Arguments
- `obj::MultiPatch`: a Gismo MultiPatch
- `geom::Geometry`: a Gismo Geometry

"""
function domainDim(object::MultiPatch)::Int
    return ccall((:gsFunctionSet_domainDim,libgismo),Cint,(Ptr{gsCFunctionSet},),object.ptr)
end

"""
Returns the target dimension of a MultiPatch

# Arguments
- `object::MultiPatch`: a Gismo MultiPatch

"""
function targetDim(object::MultiPatch)::Int
    return ccall((:gsFunctionSet_targetDim,libgismo),Cint,(Ptr{gsCFunctionSet},),object.ptr)
end

Base.show(io::IO, obj::MultiPatch) = ccall((:gsFunctionSet_print,libgismo),Cvoid,(Ptr{gsCFunctionSet},),obj.ptr)

"""
Returns the basis of a MultiPatch

# Arguments
- `obj::MultiPatch`: a Gismo MultiPatch

"""
function addPatch!(obj::MultiPatch,geom::Geometry)::Nothing
    ccall((:gsMultiPatch_addPatch,libgismo),Cvoid,(Ptr{gsCMultiPatch},Ptr{gsCGeometry},),obj.ptr,geom.ptr)
end

"""
Returns the coefficients of a MultiPatch

# Arguments
- `obj::MultiPatch`: a Gismo MultiPatch

"""
function basis(obj::MultiPatch,i::Int)::Basis
    b = ccall((:gsMultiPatch_basis,libgismo),Ptr{gsCBasis},(Ptr{gsCFunctionSet},Cint),obj.ptr,i)
    return Basis(b,false)
end

"""
Returns the coefficients of a MultiPatch

# Arguments
- `obj::MultiPatch`: a Gismo MultiPatch
- `i::Int`: the index of the patch

"""
function patch(obj::MultiPatch,i::Int)::Geometry
    g = ccall((:gsMultiPatch_patch,libgismo),Ptr{gsCGeometry},(Ptr{gsCMultiPatch},Cint),obj.ptr,i)
    return Geometry(g,false)
end

"""
Computes the topology of a MultiPatch

# Arguments
- `obj::MultiPatch`: a Gismo MultiPatch

"""
function computeTopology!(obj::MultiPatch)::Nothing
    ccall((:gsMultiPatch_computeTopology,libgismo),Cvoid,(Ptr{gsCMultiPatch},),obj.ptr)
end

"""
Returns the size of a MultiPatch (number of patches)

# Arguments
- `obj::MultiPatch`: a Gismo MultiPatch

"""
function Base.size(obj::MultiPatch)::Int
    return ccall((:gsFunctionSet_nPieces,libgismo),Cint,(Ptr{gsCFunctionSet},),obj.ptr)
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
        m = new(ccall((:gsMultiBasis_create,libgismo),Ptr{gsCMultiBasis},(),) )
        finalizer(destroy!, m)
        return m
    end

    function destroy!(m::MultiBasis)
        ccall((:gsMultiBasis_delete,libgismo),Cvoid,(Ptr{gsCFunctionSet},),m.ptr)
    end
end

"""
Returns the basus of a MultiBasis

# Arguments
- `obj::MultiBasis`: a Gismo MultiBasis
- `i::Int`: the index of the basis

"""
function basis(obj::MultiBasis,i::Int)::Basis
    b = ccall((:gsMultiBasis_basis,libgismo),Ptr{gsCBasis},(Ptr{gsCFunctionSet},Cint),obj.ptr,i)
    return Basis(b,false)
end