export
    THBSplineBasis,
    HBSplineBasis,
    THBSpline,
    HBSpline,
    tensorLevel,
    getLevelAtPoint,
    getElementData
########################################################################
# gsTHBSplineBasis
########################################################################

"""
    THBSplineBasis(basis::Basis, manualLevels::Bool=false)

# Arguments
- `basis::Basis`: a basis object
- `manualLevels::Bool`: a flag indicating whether to use manual levels (default: false)

# Examples
```jldoctest output=(false)
kv = KnotVector([0.,0.,0.,1.,1.,1.])
b = BSplineBasis(kv)
thb = THBSplineBasis(b)
# output
```
"""
function THBSplineBasis(basis::Basis, manualLevels::Bool=false)::Basis
    if (domainDim(basis)==1)
        b = ccall((:gsTHBSplineBasis1_create,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},Cint),basis.ptr,manualLevels ? 1 : 0)
    elseif (domainDim(basis)==2)
        b = ccall((:gsTHBSplineBasis2_create,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},Cint),basis.ptr,manualLevels ? 1 : 0)
    elseif (domainDim(basis)==3)
        b = ccall((:gsTHBSplineBasis3_create,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},Cint),basis.ptr,manualLevels ? 1 : 0)
    elseif (domainDim(basis)==4)
        b = ccall((:gsTHBSplineBasis4_create,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},Cint),basis.ptr,manualLevels ? 1 : 0)
    else
        error("THBSplineBasis not implemented for this dimension")
    end
    return Basis(b)
end

"""
    HBSplineBasis(basis::Basis, manualLevels::Bool=false)

# Arguments
- `basis::Basis`: a basis object
- `manualLevels::Bool`: a flag indicating whether to use manual levels (default: false)

# Examples
```jldoctest output=(false)
kv = KnotVector([0.,0.,0.,1.,1.,1.])
b = BSplineBasis(kv)
thb = HBSplineBasis(b)
# output
```
"""
function HBSplineBasis(basis::Basis, manualLevels::Bool=false)::Basis
    if (domainDim(basis)==1)
        b = ccall((:gsHBSplineBasis1_create,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},Cint),basis.ptr,manualLevels ? 1 : 0)
    elseif (domainDim(basis)==2)
        b = ccall((:gsHBSplineBasis2_create,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},Cint),basis.ptr,manualLevels ? 1 : 0)
    elseif (domainDim(basis)==3)
        b = ccall((:gsHBSplineBasis3_create,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},Cint),basis.ptr,manualLevels ? 1 : 0)
    elseif (domainDim(basis)==4)
        b = ccall((:gsHBSplineBasis4_create,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},Cint),basis.ptr,manualLevels ? 1 : 0)
    else
        error("HBSplineBasis not implemented for this dimension")
    end
    return Basis(b)
end

"""
    THBSpline(basis::Basis, coefs::Matrix{Cdouble})

# Arguments
- `basis::Basis`: a basis object
- `coefs::Matrix{Cdouble}`: a matrix of coefficients

# Examples
```jldoctest output=(false)
kv = KnotVector([0.,0.,0.,1.,1.,1.])
b = BSplineBasis(kv)
thb = THBSplineBasis(b)
coefs = rand(3,2)
g = THBSpline(thb,coefs)
# output
```
"""
function THBSpline(basis::Basis, coefs::Matrix{Cdouble})::Geometry
    @assert Base.size(coefs,1) == Gismo.size(basis) "THBSpline: coefs must have the same number of rows as the number of degrees of freedom"
    cc = EigenMatrix(Base.size(coefs,1),Base.size(coefs,2),pointer(coefs))
    if (domainDim(basis)==1)
        g = ccall((:gsTHBSpline1_create,libgismo),Ptr{gsCGeometry},(Ptr{gsCBasis},Ptr{EigenMatrix}),basis.ptr,cc.ptr)
    elseif (domainDim(basis)==2)
        g = ccall((:gsTHBSpline2_create,libgismo),Ptr{gsCGeometry},(Ptr{gsCBasis},Ptr{EigenMatrix}),basis.ptr,cc.ptr)
    elseif (domainDim(basis)==3)
        g = ccall((:gsTHBSpline3_create,libgismo),Ptr{gsCGeometry},(Ptr{gsCBasis},Ptr{EigenMatrix}),basis.ptr,cc.ptr)
    elseif (domainDim(basis)==4)
        g = ccall((:gsTHBSpline4_create,libgismo),Ptr{gsCGeometry},(Ptr{gsCBasis},Ptr{EigenMatrix}),basis.ptr,cc.ptr)
    else
        error("THBSpline not implemented for this dimension")
    end
    return Geometry(g)
end

"""
    HBSpline(basis::Basis, coefs::Matrix{Cdouble})

# Arguments
- `basis::Basis`: a basis object
- `coefs::Matrix{Cdouble}`: a matrix of coefficients

# Examples
```jldoctest output=(false)
kv = KnotVector([0.,0.,0.,1.,1.,1.])
b = BSplineBasis(kv)
hb = HBSplineBasis(b)
coefs = rand(3,2)
g = HBSpline(hb,coefs)
# output
```
"""
function HBSpline(basis::Basis, coefs::Matrix{Cdouble})::Geometry
    @assert Base.size(coefs,1) == Gismo.size(basis) "HBSpline: coefs must have the same number of rows as the number of degrees of freedom"
    cc = EigenMatrix(Base.size(coefs,1),Base.size(coefs,2),pointer(coefs))
    if (domainDim(basis)==1)
        g = ccall((:gsHBSpline1_create,libgismo),Ptr{gsCGeometry},(Ptr{gsCBasis},Ptr{EigenMatrix}),basis.ptr,cc.ptr)
    elseif (domainDim(basis)==2)
        g = ccall((:gsHBSpline2_create,libgismo),Ptr{gsCGeometry},(Ptr{gsCBasis},Ptr{EigenMatrix}),basis.ptr,cc.ptr)
    elseif (domainDim(basis)==3)
        g = ccall((:gsHBSpline3_create,libgismo),Ptr{gsCGeometry},(Ptr{gsCBasis},Ptr{EigenMatrix}),basis.ptr,cc.ptr)
    elseif (domainDim(basis)==4)
        g = ccall((:gsHBSpline4_create,libgismo),Ptr{gsCGeometry},(Ptr{gsCBasis},Ptr{EigenMatrix}),basis.ptr,cc.ptr)
    else
        error("HBSpline not implemented for this dimension")
    end
    return Geometry(g)
end

########################################################################

"""
Returns the tensor basis of level `level`.

# Arguments
- `level::Int`: the level
"""
function tensorLevel(basis::Basis,level::Cint)::Basis
    b = ccall((:gsHTensorBasis_tensorLevel,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},Cint),basis.ptr,level)
    return Basis(b)
end

"""
Adds a new level to the hierarchical basis.

# Arguments
- `basis::Basis`: the basis
- `level::Basis`: the level to be added (must be a tensor basis with the same domain dimension as `basis`)
"""
function addLevel(basis::Basis, level::Basis)
    @assert domainDim(basis) == domainDim(level) "addLevel: basis and level must have the same domain dimension"
    b = ccall((:gsHTensorBasis_addLevel,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},Ptr{gsCBasis}),basis.ptr,level.ptr)
    return Basis(b)
end

"""
Returns the level of the basis at a given point.

# Arguments
- `basis::Basis`: the basis
- `point::Vector{Cdouble}`: the point
"""
function getLevelAtPoint(basis::Basis,point::Vector{Cdouble})::Cint
    return getLevelAtPoint(basis,reshape(point,(length(point),1)))
end

"""
Returns the level of the basis at a given point.

# Arguments
- `basis::Basis`: the basis
- `point::Matrix{Cdouble}`: the point
"""
function getLevelAtPoint(basis::Basis,point::Matrix{Cdouble})::Cint
    @assert Base.size(point,1) == domainDim(basis) "getLevelAtPoint: point must have the same number of rows as the domain dimension"
    @assert Base.size(point,2) == 1 "getLevelAtPoint: point must have only one column"
    pt = EigenMatrix(Base.size(point,1), Base.size(point,2), pointer(point) )
    return ccall((:gsHTensorBasis_getLevelAtPoint,libgismo),Cint,(Ptr{gsCBasis},Ptr{gsCMatrix}),basis.ptr,pt.ptr)
end

"""
Returns the elements of the basis, with:
- `knotBoxes` the elements in parametric coordinates (every pair of columns is an element)
- `indexBoxes` the elements in index coordinates (every column (of length 2*d+1) is an element, with the first index the level, the second and third the index of the lower corner, and the fourth and fifth the index of the upper corner)
- `levelBoxes` the level of the elements

# Arguments
- `basis::Basis`: the basis
"""

function getElementData(basis::Basis)::Tuple{EigenMatrix,EigenMatrixInt,EigenMatrixInt}
    knotBoxes = EigenMatrix()
    indexBoxes = EigenMatrixInt()
    levelBoxes = EigenMatrixInt()
    # The following function returns:
    # - the knotBoxes (elements in parametric coordinates)
    # - the indexBoxes (elements in index coordinates)
    # - the levelBoxes (level of the elements)
    ccall((:gsHTensorBasis_elements_into,libgismo),Cvoid,(Ptr{gsCBasis},Bool,Bool,Bool,Ptr{EigenMatrix},Ptr{EigenMatrixInt},Ptr{EigenMatrixInt}),basis.ptr,true,true,true,knotBoxes.ptr,indexBoxes.ptr,levelBoxes.ptr)
    return (knotBoxes,indexBoxes,levelBoxes)
end