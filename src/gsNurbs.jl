export
    KnotVector,
    destroy!,
    show,
    size,
    uSize,
    numElements,
    BSplineBasis,
    BSpline,
    TensorBSplineBasis,
    knots,
    TensorBSpline,
    NurbsBasis,
    Nurbs,
    TensorNurbsBasis,
    TensorNurbs,
    BSplineUnitInterval,
    BSplineRectangle,
    BSplineTrapezium,
    BSplineSquare,
    BSplineSquareGrid,
    BSplineCube,
    BSplineCubeGrid,
    NurbsQuarterAnnulus,
    NurbsAnnulus,
    BSplineSaddle,
    NurbsSphere,
    NurbsCircle,
    BSplineTriangle,
    BSplineStar
    #= TODO =#

########################################################################
# gsKnotVector
########################################################################

"""
    KnotVector(filename::String)

# Arguments
- `filename::String`: the name of the file containing the knot vector

    KnotVector(a::Vector{Float64})

# Arguments
- `a::Vector{Float64}`: the knot vector

# Examples
```jldoctest myKnotVector; output=(false)
kv = KnotVector(Float64[0.,0.,0.,0.,0.5,1.,1.,1.,1.])
# output
```
"""
mutable struct KnotVector
    ptr::Ptr{gsCKnotVector}

    function KnotVector(knots::Ptr{gsCKnotVector},delete::Bool=true)
        b = new(knots)
        if (delete)
            finalizer(destroy!,b)
        end
        return b
    end

    function KnotVector(filename::String)
        g = new(ccall((:gsCReadFile,libgismo),Ptr{gsCKnotVector},(Cstring,),filename) )
        finalizer(destroy!, g)
        return g
    end

    function KnotVector(a::Vector{Float64})
        kv = new(ccall((:gsKnotVector_create,libgismo),Ptr{gsCKnotVector},(Ptr{Cdouble},Cint),a, length(a)) )
        finalizer(destroy!, kv)
        return kv
    end

    function destroy!(kv::KnotVector)
        ccall((:gsKnotVector_delete,libgismo),Cvoid,(Ptr{gsCKnotVector},),kv.ptr)
    end
end

Base.show(io::IO, obj::KnotVector) = ccall((:gsKnotVector_print,libgismo),Cvoid,(Ptr{gsCKnotVector},),obj.ptr)

"""
    size(kv::KnotVector)

Returns the number of elements in the knot vector.

# Arguments
- `kv::KnotVector`: the knot vector

# Examples
```jldoctest output=(false)
kv = KnotVector(Float64[0.,0.,0.,0.,0.5,1.,1.,1.,1.])
# output
```
"""
function Base.size(kv::KnotVector)::Int
    return ccall((:gsKnotVector_size,libgismo),Cint,(Ptr{gsCKnotVector},),kv.ptr)
end

"""
Size of the unique knots

# Arguments
- `kv::KnotVector`: the knot vector

# Examples
```jldoctest
kv = KnotVector(Float64[0.,0.,0.,0.,0.5,0.5,1.,1.,1.,1.])
print(uSize(kv))
# output
3
```
"""
function uSize(kv::KnotVector)::Int
    return ccall((:gsKnotVector_uSize,libgismo),Cint,(Ptr{gsCKnotVector},),kv.ptr)
end

"""
Number of elements in the knot vector

# Arguments
- `kv::KnotVector`: the knot vector

# Examples
```jldoctest
kv = KnotVector(Float64[0.,0.,0.,0.,0.5,1.,1.,1.,1.])
print(numElements(kv))
# output
2
```
"""
function numElements(kv::KnotVector)::Int
    return ccall((:gsKnotVector_numElements,libgismo),Cint,(Ptr{gsCKnotVector},),kv.ptr)
end

# function unique(kv::KnotVector)::Vector{Float64}
#     return ccall((:gsKnotVector_unique,libgismo),Vector{Float64},(Ptr{gsCKnotVector},),kv.ptr)
# end

########################################################################
# gsBSplineBasis
########################################################################

"""
    BSplineBasis(kv::KnotVector)

Defines a B-spline basis.

# Arguments
- `kv::KnotVector`: the knot vector
"""
function BSplineBasis(kv::KnotVector)::Basis
    b = ccall((:gsBSplineBasis_create,libgismo),Ptr{gsCBasis},(Ptr{gsCKnotVector},),kv.ptr)
    return Basis(b)
end

########################################################################
# gsBSpline
########################################################################

"""
    BSpline(basis::Basis,coefs::Matrix{Cdouble})

Defines a B-spline geometry.

# Arguments
- `basis::Basis`: the basis
- `coefs::Matrix{Cdouble}`: the coefficients
"""
function BSpline(basis::Basis,coefs::Matrix{Cdouble})::Geometry
    @assert Base.size(coefs,1)==Gismo.size(basis) "Number of rows of the coefficients should be equal to the number of elements of the basis"
    cc = EigenMatrix(Base.size(coefs,1), Base.size(coefs,2), pointer(coefs) )
    g = ccall((:gsBSpline_create,libgismo),Ptr{gsCGeometry},
              (Ptr{gsCBasis},Ptr{gsCMatrix},),
              basis.ptr,cc.ptr)
    return Geometry(g)
end

########################################################################
# gsTensorBSplineBasis
########################################################################

"""
    TensorBSplineBasis(kv1::KnotVector,kv2::KnotVector)

Defines a 2D tensor B-spline basis.

# Arguments
- `kv::KnotVector`: the knot vectors
"""
function TensorBSplineBasis(kv::Vararg{KnotVector})::Basis
    d = Base.length(kv)
    if (d==1)
        b = ccall((:gsBSplineBasis_create,libgismo),Ptr{gsCBasis},(Ptr{gsCKnotVector},),kv[1].ptr)
    elseif (d==2)
        b = ccall((:gsTensorBSplineBasis2_create,libgismo),Ptr{gsCBasis},(Ptr{gsCKnotVector},Ptr{gsCKnotVector},),kv[1].ptr,kv[2].ptr)
    elseif (d==3)
        b = ccall((:gsTensorBSplineBasis3_create,libgismo),Ptr{gsCBasis},(Ptr{gsCKnotVector},
                                                                         Ptr{gsCKnotVector},
                                                                         Ptr{gsCKnotVector},),
                                                                        kv[1].ptr,
                                                                        kv[2].ptr,
                                                                        kv[3].ptr)
    elseif (d==4)
        b = ccall((:gsTensorBSplineBasis4_create,libgismo),Ptr{gsCBasis},(Ptr{gsCKnotVector},
                                                                         Ptr{gsCKnotVector},
                                                                         Ptr{gsCKnotVector},
                                                                         Ptr{gsCKnotVector},),
                                                                        kv[1].ptr,
                                                                        kv[2].ptr,
                                                                        kv[3].ptr,
                                                                        kv[4].ptr)
    else
        error("TensorBSplineBasis not implemented for this dimension")
    end
    return Basis(b)
end

function knots(basis::Basis, dir::Int)::KnotVector
    if (domainDim(basis)==1)
        kv = ccall((:gsBSplineBasis_knots,libgismo),Ptr{gsCKnotVector},(Ptr{gsCBasis},Cint),basis.ptr,dir)
    else
        kv = ccall((:gsTensorBSplineBasis_knots,libgismo),Ptr{gsCKnotVector},(Ptr{gsCBasis},Cint),basis.ptr,dir)
    end
    return KnotVector(kv)
end

########################################################################
# gsTensorBSpline
########################################################################

"""
    TensorBSpline(basis::Basis,coefs::Matrix{Cdouble})

Defines a tensor B-spline geometry.

# Arguments
- `basis::Basis`: the basis
- `coefs::Matrix{Cdouble}`: the coefficients
"""
function TensorBSpline(basis::Basis,coefs::Matrix{Cdouble})::Geometry
    @assert Base.size(coefs,1)==Gismo.size(basis) "Number of rows of the coefficients should be equal to the number of elements of the basis"
    cc = EigenMatrix(Base.size(coefs,1), Base.size(coefs,2), pointer(coefs) )
    if (domainDim(basis)==2)
        g = ccall((:gsTensorBSpline2_create,libgismo),Ptr{gsCGeometry},
              (Ptr{gsCBasis},Ptr{gsCMatrix},),
              basis.ptr,cc.ptr)
    elseif (domainDim(basis)==3)
        g = ccall((:gsTensorBSpline3_create,libgismo),Ptr{gsCGeometry},
              (Ptr{gsCBasis},Ptr{gsCMatrix},),
              basis.ptr,cc.ptr)
    elseif (domainDim(basis)==4)
        g = ccall((:gsTensorBSpline4_create,libgismo),Ptr{gsCGeometry},
              (Ptr{gsCBasis},Ptr{gsCMatrix},),
              basis.ptr,cc.ptr)
    else
        error("TensorBSpline not implemented for this dimension")
    end
    return Geometry(g)
end


########################################################################
# gsNurbsBasis
########################################################################

"""
    NurbsBasis(kv::KnotVector)

Defines a NURBS basis.

# Arguments
- `kv::KnotVector`: the knot vector
"""
function NurbsBasis(kv::KnotVector)::Basis
    b = ccall((:gsNurbsBasis_create,libgismo),Ptr{gsCBasis},(Ptr{gsCKnotVector},),kv.ptr)
    return Basis(b)
end

########################################################################
# gsNurbs
########################################################################

"""
    Nurbs(basis::Basis,coefs::Matrix{Cdouble})

Defines a NURBS geometry.

# Arguments
- `basis::Basis`: the basis
- `coefs::Matrix{Cdouble}`: the coefficients
"""
function Nurbs(basis::Basis,coefs::Matrix{Cdouble})::Geometry
    @assert Base.size(coefs,1)==Gismo.size(basis) "Number of rows of the coefficients should be equal to the number of elements of the basis"
    cc = EigenMatrix(Base.size(coefs,1), Base.size(coefs,2), pointer(coefs) )
    g = ccall((:gsNurbs_create,libgismo),Ptr{gsCGeometry},
              (Ptr{gsCBasis},Ptr{gsCMatrix},),
              basis.ptr,cc.ptr)
    return Geometry(g)
end

########################################################################
# gsTensorNurbsBasis
########################################################################

"""
    TensorNurbsBasis(kv1::KnotVector,kv2::KnotVector)

Defines a 2D tensor NURBS basis.

# Arguments
- `kv::KnotVector`: knot vectors
"""
function TensorNurbsBasis(kv::Vararg{KnotVector})::Basis
    d = Base.length(kv)
    if (d==1)
        b = ccall((:gsNurbsBasis_create,libgismo),Ptr{gsCBasis},(Ptr{gsCKnotVector},),kv[1].ptr)
    elseif (d==2)
        b = ccall((:gsTensorNurbsBasis2_create,libgismo),Ptr{gsCBasis},(Ptr{gsCKnotVector},Ptr{gsCKnotVector},),kv[1].ptr,kv[2].ptr)
    elseif (d==3)
        b = ccall((:gsTensorNurbsBasis3_create,libgismo),Ptr{gsCBasis},(Ptr{gsCKnotVector},
                                                                         Ptr{gsCKnotVector},
                                                                         Ptr{gsCKnotVector},),
                                                                        kv[1].ptr,
                                                                        kv[2].ptr,
                                                                        kv[3].ptr)
    elseif (d==4)
        b = ccall((:gsTensorNurbsBasis4_create,libgismo),Ptr{gsCBasis},(Ptr{gsCKnotVector},
                                                                         Ptr{gsCKnotVector},
                                                                         Ptr{gsCKnotVector},
                                                                         Ptr{gsCKnotVector},),
                                                                        kv[1].ptr,
                                                                        kv[2].ptr,
                                                                        kv[3].ptr,
                                                                        kv[4].ptr)
    else
        error("TensorNurbsBasis not implemented for this dimension")
    end
end

########################################################################
# gsTensorNurbs
########################################################################

"""
    TensorNurbs(basis::Basis,coefs::Matrix{Cdouble})

Defines a tensor NURBS geometry.

# Arguments
- `basis::Basis`: the basis
- `coefs::Matrix{Cdouble}`: the coefficients
"""
function TensorNurbs(basis::Basis,coefs::Matrix{Cdouble})::Geometry
    @assert Base.size(coefs,1)==Gismo.size(basis) "Number of rows of the coefficients should be equal to the number of elements of the basis"
    cc = EigenMatrix(Base.size(coefs,1), Base.size(coefs,2), pointer(coefs) )
    if (domainDim(basis)==2)
        g = ccall((:gsTensorNurbs2_create,libgismo),Ptr{gsCGeometry},
              (Ptr{gsCBasis},Ptr{gsCMatrix},),
              basis.ptr,cc.ptr)
    elseif (domainDim(basis)==3)
        g = ccall((:gsTensorNurbs3_create,libgismo),Ptr{gsCGeometry},
              (Ptr{gsCBasis},Ptr{gsCMatrix},),
              basis.ptr,cc.ptr)
    elseif (domainDim(basis)==4)
        g = ccall((:gsTensorNurbs4_create,libgismo),Ptr{gsCGeometry},
              (Ptr{gsCBasis},Ptr{gsCMatrix},),
              basis.ptr,cc.ptr)
    else
        error("TensorNurbs not implemented for this dimension")
    end
    return Geometry(g)
end

########################################################################
# gsNurbsCreator
########################################################################

"""
Create a unit interval represented by a B-spline

# Arguments
- `deg::Int`: the degree of the B-spline

# Examples
```jldoctest output=(false)
g = BSplineUnitInterval(2)
# output
```
"""
function BSplineUnitInterval(deg::Int)::Geometry
    g = ccall((:gsNurbsCreator_BSplineUnitInterval,libgismo),Ptr{gsCGeometry},(Cint,),deg)
    return Geometry(g)
end

"""
Create a rectangle represented by a B-spline

# Arguments
- `low_x::Cdouble`: the lower bound in x
- `low_y::Cdouble`: the lower bound in y
- `upp_x::Cdouble`: the upper bound in x
- `upp_y::Cdouble`: the upper bound in y
- `turndeg::Cdouble`: the turning degree

# Examples
```jldoctest output=(false)
g = BSplineRectangle(0.0,0.0,1.0,1.0,0.0)
# output
```
"""
function BSplineRectangle(low_x::Cdouble=0.0,
                          low_y::Cdouble=0.0,
                          upp_x::Cdouble=1.0,
                          upp_y::Cdouble=1.0,
                          turndeg::Cdouble=0.0)::Geometry
    g = ccall((:gsNurbsCreator_BSplineRectangle,libgismo),Ptr{gsCGeometry},(Cdouble,Cdouble,Cdouble,Cdouble,Cdouble),low_x,low_y,upp_x,upp_y,turndeg)
    return Geometry(g)
end

"""
Create a trapezium represented by a B-spline

# Arguments
- `Lbot::Cdouble`: the length of the bottom side
- `Ltop::Cdouble`: the length of the top side
- `H::Cdouble`: the height
- `d::Cdouble`: the offset of the top-side w.r.t. the bottom side
- `turndeg::Cdouble`: the turning degree

# Examples
```jldoctest output=(false)
g = BSplineTrapezium(1.0,0.5,1.0,0.0,0.0)
# output
```
"""
function BSplineTrapezium(Lbot::Cdouble=1.0,
                          Ltop::Cdouble=0.5,
                          H::Cdouble=1.0,
                          d::Cdouble=0.0,
                          turndeg::Cdouble=0.0)::Geometry
    g = ccall((:gsNurbsCreator_BSplineTrapezium,libgismo),Ptr{gsCGeometry},(Cdouble,Cdouble,Cdouble,Cdouble,Cdouble),Lbot,Ltop,H,d,turndeg)
    return Geometry(g)
end

"""
Create a square represented by a B-spline

# Arguments
- `r::Cdouble`: the radius of the square
- `x::Cdouble`: the x-coordinate of the center
- `y::Cdouble`: the y-coordinate of the center

# Examples
```jldoctest output=(false)
g = BSplineSquare(1.0,0.0,0.0)
# output
```
"""
function BSplineSquare(r::Cdouble=1.0,
                       x::Cdouble=0.0,
                       y::Cdouble=0.0)::Geometry
    g = ccall((:gsNurbsCreator_BSplineSquare,libgismo),Ptr{gsCGeometry},(Cdouble,Cdouble,Cdouble),r,x,y)
    return Geometry(g)
end

"""
Create a square grid represented by a multi-patch

# Arguments
- `n::Int`: the number of patches in x-direction
- `m::Int`: the number of patches in y-direction
- `r::Cdouble`: the radius of the square
- `lx::Cdouble`: the x-coordinate of the center
- `ly::Cdouble`: the y-coordinate of the center

# Examples
```jldoctest output=(false)
g = BSplineSquareGrid(2,2,1.0,0.0,0.0)
# output
```
"""
function BSplineSquareGrid(n::Int,
                           m::Int,
                           r::Cdouble=1.0,
                           lx::Cdouble=0.0,
                           ly::Cdouble=0.0)::MultiPatch
    g = ccall((:gsNurbsCreator_BSplineSquareGrid,libgismo),Ptr{gsCMultiPatch},(Cint,Cint,Cdouble,Cdouble,Cdouble),n,m,r,lx,ly)
    return MultiPatch(g)
end

"""
Create a cube represented by a B-spline

# Arguments
- `r::Cdouble`: the radius of the cube
- `x::Cdouble`: the x-coordinate of the center
- `y::Cdouble`: the y-coordinate of the center
- `z::Cdouble`: the z-coordinate of the center

# Examples
```jldoctest output=(false)
g = BSplineCube(1.0,0.0,0.0,0.0)
# output
```
"""
function BSplineCube(r::Cdouble=1.0,
                     x::Cdouble=0.0,
                     y::Cdouble=0.0,
                     z::Cdouble=0.0)::Geometry
    g = ccall((:gsNurbsCreator_BSplineCube,libgismo),Ptr{gsCGeometry},(Cdouble,Cdouble,Cdouble,Cdouble),r,x,y,z)
    return Geometry(g)
end

"""
Create a cube grid represented by a multi-patch

# Arguments
- `n::Int`: the number of patches in x-direction
- `m::Int`: the number of patches in y-direction
- `p::Int`: the number of patches in z-direction
- `r::Cdouble`: the radius of the cube
- `lx::Cdouble`: the x-coordinate of the center
- `ly::Cdouble`: the y-coordinate of the center
- `lz::Cdouble`: the z-coordinate of the center

# Examples
```jldoctest output=(false)
g = BSplineCubeGrid(2,2,2,1.0,0.0,0.0,0.0)
# output
```
"""
function BSplineCubeGrid(n::Int,
                         m::Int,
                         p::Int,
                         r::Cdouble=1.0,
                         lx::Cdouble=0.0,
                         ly::Cdouble=0.0,
                         lz::Cdouble=0.0)::MultiPatch
    g = ccall((:gsNurbsCreator_BSplineCubeGrid,libgismo),Ptr{gsCMultiPatch},(Cint,Cint,Cint,Cdouble,Cdouble,Cdouble,Cdouble),n,m,p,r,lx,ly,lz)
    return MultiPatch(g)
end

"""
Create a quarter annulus represented by a NURBS

# Arguments
- `r1::Cdouble`: the inner radius
- `r2::Cdouble`: the outer radius

# Examples
```jldoctest output=(false)
g = NurbsQuarterAnnulus(1.0,2.0)
# output
```
"""
function NurbsQuarterAnnulus(r1::Cdouble=1.0,
                             r2::Cdouble=2.0)::Geometry
    g = ccall((:gsNurbsCreator_NurbsQuarterAnnulus,libgismo),Ptr{gsCGeometry},(Cdouble,Cdouble),r1,r2)
    return Geometry(g)
end

"""
Create an annulus represented by a NURBS

# Arguments
- `r1::Cdouble`: the inner radius
- `r2::Cdouble`: the outer radius

# Examples
```jldoctest output=(false)
g = NurbsAnnulus(1.0,2.0)
# output
```
"""
function NurbsAnnulus(r1::Cdouble=1.0,
                      r2::Cdouble=2.0)::Geometry
    g = ccall((:gsNurbsCreator_NurbsAnnulus,libgismo),Ptr{gsCGeometry},(Cdouble,Cdouble),r1,r2)
    return Geometry(g)
end

"""
Create a saddle represented by a B-spline

# Examples
```jldoctest output=(false)
g = BSplineSaddle()
# output
```
"""
function BSplineSaddle()::Geometry
    g = ccall((:gsNurbsCreator_BSplineSaddle,libgismo),Ptr{gsCGeometry},(),)
    return Geometry(g)
end

"""
Create a sphere represented by a NURBS

# Arguments
- `r::Cdouble`: the radius
- `x::Cdouble`: the x-coordinate of the center
- `y::Cdouble`: the y-coordinate of the center
- `z::Cdouble`: the z-coordinate of the center

# Examples
```jldoctest output=(false)
g = NurbsSphere(1.0,0.0,0.0,0.0)
# output
```
"""
function NurbsSphere(r::Cdouble=1.0,
                     x::Cdouble=0.0,
                     y::Cdouble=0.0,
                     z::Cdouble=0.0)::Geometry
    g = ccall((:gsNurbsCreator_NurbsSphere,libgismo),Ptr{gsCGeometry},(Cdouble,Cdouble,Cdouble,Cdouble),r,x,y,z)
    return Geometry(g)
end

"""
Create a circle represented by a NURBS

# Arguments
- `r::Cdouble`: the radius
- `x::Cdouble`: the x-coordinate of the center
- `y::Cdouble`: the y-coordinate of the center

# Examples
```jldoctest output=(false)
g = NurbsCircle(1.0,0.0,0.0)
# output
```
"""
function NurbsCircle(r::Cdouble=1.0,
                     x::Cdouble=0.0,
                     y::Cdouble=0.0)::Geometry
    g = ccall((:gsNurbsCreator_NurbsCircle,libgismo),Ptr{gsCGeometry},(Cdouble,Cdouble,Cdouble),r,x,y)
    return Geometry(g)
end

"""
Create a triangle represented by a B-spline

# Arguments
- `H::Cdouble`: the height
- `W::Cdouble`: the width

# Examples
```jldoctest output=(false)
g = BSplineTriangle(1.0,1.0)
# output
```
"""
function BSplineTriangle(H::Cdouble=1.0,
                         W::Cdouble=1.0)::Geometry
    g = ccall((:gsNurbsCreator_BSplineTriangle,libgismo),Ptr{gsCGeometry},(Cdouble,Cdouble),H,W)
    return Geometry(g)
end

"""
Create a star represented by a multi-patch

# Arguments
- `N::Int`: the number of arms
- `R0::Cdouble`: the outer radius
- `R1::Cdouble`: the inner radius

# Examples
```jldoctest output=(false)
g = BSplineStar(3,1.0,0.5)
# output
```
"""
function BSplineStar(N::Int=3,
                     R0::Cdouble=1.0,
                     R1::Cdouble=0.5)::MultiPatch
    g = ccall((:gsNurbsCreator_BSplineStar,libgismo),Ptr{gsCMultiPatch},(Cint,Cdouble,Cdouble),N,R0,R1)
    return MultiPatch(g)
end