export
EigenMatrix,
destroy!,
show,
rows,
cols,
data,
asMatrix,
asVector,
toMatrix,
toVector,
setZero!,
EigenMatrixInt,
asMatrixInt,
asVectorInt,
toMatrixInt,
toVectorInt,
deepcopy

########################################################################
# gsMatrix
########################################################################

"""
    EigenMatrix()

Creates an empty matrix.

# Example

```jldoctest output=(false)
m = EigenMatrix()
# output
```
"""
mutable struct EigenMatrix
    ptr::Ptr{gsCMatrix}

    function EigenMatrix()
        m = new( ccall((:gsMatrix_create,libgismo),Ptr{gsCMatrix},()) )
        finalizer(destroy!, m)
        return m
    end

    function EigenMatrix(r::Int,c::Int)
        m = new(ccall((:gsMatrix_create_rc,libgismo),Ptr{gsCMatrix},
                     (Cint,Cint), r, c) )
        finalizer(destroy!, m)
        return m
    end

    function EigenMatrix(r::Int,c::Int, data::Ptr{Cdouble})
        m = new(ccall((:gsMatrix_create_rcd,libgismo),Ptr{gsCMatrix},
                     (Cint,Cint,Ptr{Cdouble},), r, c, data) )
        finalizer(destroy!, m)
        return m
    end

    function destroy!(m::EigenMatrix)
        ccall((:gsMatrix_delete,libgismo),Cvoid,(Ptr{gsCMatrix},),m.ptr)
    end
end

"""
Returns the number of rows in the matrix.

# Arguments
- `object::EigenMatrix`: the matrix

# Examples
```jldoctest myEigenMatrix
m = EigenMatrix(3,3)
print(Gismo.rows(m))
# output
3
```
"""
function rows(object::EigenMatrix)::Int
    return ccall((:gsMatrix_rows,libgismo),Cint,(Ptr{gsCMatrix},),object.ptr)
end

"""
Returns the number of columns in the matrix.

# Arguments
- `object::EigenMatrix`: the matrix

# Examples
```jldoctest myEigenMatrix
m = EigenMatrix(3,3)
print(Gismo.cols(m))
# output
3
```
"""
function cols(object::EigenMatrix)::Int
    return ccall((:gsMatrix_cols,libgismo),Cint,(Ptr{gsCMatrix},),object.ptr)
end

"""
Returns a pointer to the data of the matrix.

# Arguments
- `object::EigenMatrix`: the matrix

"""
function data(object::EigenMatrix)::Ptr{Cdouble}
    return ccall((:gsMatrix_data,libgismo),Ptr{Cdouble},(Ptr{gsCMatrix},),object.ptr)
end

"""
Returns the matrix as a Julia matrix (transfers ownership).

# Arguments
- `object::EigenMatrix`: the matrix

"""
function toMatrix(object::EigenMatrix)::Matrix{Cdouble}
    return unsafe_wrap(Array, data(object), (rows(object),cols(object)); own = true)
end

"""
Returns the matrix as a Julia vector (transfers ownership).

# Arguments
- `object::EigenMatrix`: the matrix

"""
function toVector(object::EigenMatrix)::Vector{Cdouble}
    return unsafe_wrap(Array, data(object), (rows(object)); own = true)
end

"""
Returns the matrix as a Julia matrix.

# Arguments
- `object::EigenMatrix`: the matrix

"""
function asMatrix(object::EigenMatrix)::Matrix{Cdouble}
    return unsafe_wrap(Array, Base.unsafe_convert(Ptr{Cdouble},data(object)), (rows(object),cols(object)); own = false)
end

"""
Returns the matrix as a Julia vector.

# Arguments
- `object::EigenMatrix`: the matrix

"""
function asVector(object::EigenMatrix)::Vector{Cdouble}
    return unsafe_wrap(Array, data(object), (rows(object)); own = false)
end

Base.deepcopy(obj::EigenMatrix) = EigenMatrix(rows(obj),cols(obj),data(obj))

Base.show(io::IO, obj::EigenMatrix) = ccall((:gsMatrix_print,libgismo),Cvoid,(Ptr{gsCMatrix},),obj.ptr)

"""
Sets all the elements of the matrix to zero.

# Arguments
- `object::EigenMatrix`: the matrix

"""
function setZero!(object::EigenMatrix)::Nothing
    ccall((:gsMatrix_setZero,libgismo),Cvoid,(Ptr{gsCMatrix},),object.ptr)
end

########################################################################
# gsMatrixInt
########################################################################

mutable struct EigenMatrixInt
    ptr::Ptr{gsCMatrixInt}

    """
    Creates an empty matrix.
    """
    function EigenMatrixInt()
        m = new( ccall((:gsMatrixInt_create,libgismo),Ptr{gsCMatrixInt},()) )
        finalizer(destroy!, m)
        return m
    end

    """
    Creates an empty matrix

    # Arguments
    - `r::Int`: the number of rows
    - `c::Int`: the number of columns
    """
    function EigenMatrixInt(r::Int,c::Int)
        m = new(ccall((:gsMatrixInt_create_rc,libgismo),Ptr{gsCMatrixInt},
                     (Cint,Cint), r, c) )
        finalizer(destroy!, m)
        return m
    end

    """
    Creates a matrix from a pointer to the data

    # Arguments
    - `r::Int`: the number of rows
    - `c::Int`: the number of columns
    - `data::Ptr{Cint}`: the pointer to the data
    """
    function EigenMatrixInt(r::Int,c::Int, data::Ptr{Cint})
        m = new(ccall((:gsMatrixInt_create_rcd,libgismo),Ptr{gsCMatrixInt},
                     (Cint,Cint,Ptr{Cint},), r, c, data) )
        finalizer(destroy!, m)
        return m
    end

    function destroy!(m::EigenMatrixInt)
        ccall((:gsMatrixInt_delete,libgismo),Cvoid,(Ptr{gsCMatrixInt},),m.ptr)
    end
end

"""
Returns the number of rows in the matrix.

# Arguments
- `object::EigenMatrixInt`: the matrix

# Examples
```jldoctest myEigenMatrixInt
m = EigenMatrixInt(3,3)
print(Gismo.rows(m))
# output
3
```
"""
function rows(object::EigenMatrixInt)::Int
    return ccall((:gsMatrixInt_rows,libgismo),Cint,(Ptr{gsCMatrixInt},),object.ptr)
end

"""
Returns the number of columns in the matrix.

# Arguments
- `object::EigenMatrixInt`: the matrix

# Examples
```jldoctest myEigenMatrixInt
m = EigenMatrixInt(3,3)
print(Gismo.cols(m))
# output
3
```
"""
function cols(object::EigenMatrixInt)::Int
    return ccall((:gsMatrixInt_cols,libgismo),Cint,(Ptr{gsCMatrixInt},),object.ptr)
end

"""
Returns a pointer to the data of the matrix.

# Arguments
- `object::EigenMatrixInt`: the matrix

"""
function data(object::EigenMatrixInt)::Ptr{Int}
    return ccall((:gsMatrixInt_data,libgismo),Ptr{Cint},(Ptr{gsCMatrixInt},),object.ptr)
end

"""
Returns the matrix as a Julia matrix (transfers ownership).

# Arguments
- `object::EigenMatrixInt`: the matrix

"""
function toMatrixInt(object::EigenMatrixInt)::MatrixInt{Int}
    return unsafe_wrap(Array, data(object), (rows(object),cols(object)); own = true)
end

"""
Returns the matrix as a Julia vector (transfers ownership).

# Arguments
- `object::EigenMatrixInt`: the matrix

"""
function toVectorInt(object::EigenMatrixInt)::Vector{Int}
    return unsafe_wrap(Array, data(object), (rows(object)); own = true)
end

"""
Returns the matrix as a Julia matrix.

# Arguments
- `object::EigenMatrixInt`: the matrix

"""
function asMatrixInt(object::EigenMatrixInt)::MatrixInt{Int}
    return unsafe_wrap(Array, data(object), (rows(object),cols(object)); own = false)
end

"""
Returns the matrix as a Julia vector.

# Arguments
- `object::EigenMatrixInt`: the matrix

"""
function asVectorInt(object::EigenMatrixInt)::Vector{Int}
    return unsafe_wrap(Array, data(object), (rows(object)); own = false)
end

Base.deepcopy(obj::EigenMatrixInt) = EigenMatrixInt(rows(obj),cols(obj),data(obj))

# Base.show(io::IO, obj::EigenMatrixInt) = asMatrixInt(obj)
Base.show(io::IO, obj::EigenMatrixInt) = ccall((:gsMatrixInt_print,libgismo),Cvoid,(Ptr{gsCMatrixInt},),obj.ptr)

"""
Sets all the elements of the matrix to zero.

# Arguments
- `object::EigenMatrixInt`: the matrix

"""
function setZero!(object::EigenMatrixInt)::Nothing
    ccall((:gsMatrixInt_setZero,libgismo),Cvoid,(Ptr{gsCMatrixInt},),object.ptr)
end

