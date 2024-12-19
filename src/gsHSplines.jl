export
    THBSplineBasis,
    HBSplineBasis,
    THBSpline,
    HBSpline
########################################################################
# gsTHBSplineBasis
########################################################################

"""
    THBSplineBasis(basis::Basis)

# Arguments
- `basis::Basis`: a basis object

# Examples
```jldoctest output=(false)
kv = KnotVector([0.,0.,0.,1.,1.,1.])
b = BSplineBasis(kv)
thb = THBSplineBasis(b)
# output
```
"""
function THBSplineBasis(basis::Basis)::Basis
    if (domainDim(basis)==1)
        b = ccall((:gsTHBSplineBasis1_create,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},),basis.ptr)
    elseif (domainDim(basis)==2)
        b = ccall((:gsTHBSplineBasis2_create,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},),basis.ptr)
    elseif (domainDim(basis)==3)
        b = ccall((:gsTHBSplineBasis3_create,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},),basis.ptr)
    elseif (domainDim(basis)==4)
        b = ccall((:gsTHBSplineBasis4_create,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},),basis.ptr)
    else
        error("THBSplineBasis not implemented for this dimension")
    end
    return Basis(b)
end

"""
    HBSplineBasis(basis::Basis)

# Arguments
- `basis::Basis`: a basis object

# Examples
```jldoctest output=(false)
kv = KnotVector([0.,0.,0.,1.,1.,1.])
b = BSplineBasis(kv)
thb = HBSplineBasis(b)
# output
```
"""
function HBSplineBasis(basis::Basis)::Basis
    if (domainDim(basis)==1)
        b = ccall((:gsHBSplineBasis1_create,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},),basis.ptr)
    elseif (domainDim(basis)==2)
        b = ccall((:gsHBSplineBasis2_create,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},),basis.ptr)
    elseif (domainDim(basis)==3)
        b = ccall((:gsHBSplineBasis3_create,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},),basis.ptr)
    elseif (domainDim(basis)==4)
        b = ccall((:gsHBSplineBasis4_create,libgismo),Ptr{gsCBasis},(Ptr{gsCBasis},),basis.ptr)
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