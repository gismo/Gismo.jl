using SparseArrays

export
       EigenMatrix,
       destroy!,
       show,
       rows,
       cols,
       data,
       copyMatrix,
       copyVector,
       setZero!,
       EigenMatrixInt,
       deepcopy,
       EigenSparseMatrix,
# findnz,
       nnz

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

    """
    Creates an empty matrix.
    """
    function EigenMatrix()
        m = new(ccall((:gsMatrix_create, libgismo), Ptr{gsCMatrix}, ()))
        finalizer(destroy!, m)
        return m
    end

    """
    Creates an empty matrix

    # Arguments
    - `r::Int`: the number of rows
    - `c::Int`: the number of columns
    """
    function EigenMatrix(r::Int, c::Int)
        m = new(ccall((:gsMatrix_create_rc, libgismo), Ptr{gsCMatrix},
            (Cint, Cint), r, c))
        finalizer(destroy!, m)
        return m
    end

    """
    Creates a matrix from a Julia matrix

    # Arguments
    - `M::Matrix{Cint}`: the matrix
    """
    function EigenMatrix(M::Matrix{Cdouble})
        m = new(ccall((:gsMatrix_create_rcd, libgismo), Ptr{gsCMatrix},
            (Cint, Cint, Ptr{Cdouble}), size(M, 1), size(M, 2), M))
        finalizer(destroy!, m)
        return m
    end

    """
    Creates a matrix from a pointer to the data

    # Arguments
    - `r::Int`: the number of rows
    - `c::Int`: the number of columns
    - `data::Ptr{Cdouble}`: the pointer to the data
    """
    function EigenMatrix(r::Int, c::Int, data::Ptr{Cdouble})
        m = new(ccall((:gsMatrix_create_rcd, libgismo), Ptr{gsCMatrix},
            (Cint, Cint, Ptr{Cdouble}), r, c, data))
        finalizer(destroy!, m)
        return m
    end

    function destroy!(m::EigenMatrix)
        ccall((:gsMatrix_delete, libgismo), Cvoid, (Ptr{gsCMatrix},), m.ptr)
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
    return ccall((:gsMatrix_rows, libgismo), Cint, (Ptr{gsCMatrix},), object.ptr)
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
    return ccall((:gsMatrix_cols, libgismo), Cint, (Ptr{gsCMatrix},), object.ptr)
end

"""
Returns a pointer to the data of the matrix.

# Arguments
- `object::EigenMatrix`: the matrix

"""
function data(object::EigenMatrix)::Ptr{Cdouble}
    return ccall((:gsMatrix_data, libgismo), Ptr{Cdouble}, (Ptr{gsCMatrix},), object.ptr)
end

"""
Returns the matrix as a Julia matrix.

# Arguments
- `object::EigenMatrix`: the matrix

# Notes:
This is the safe and robust way to create a Julia Matrix from C++ 'new'-allocated data
It does not transfer ownership of the data, so the Julia Matrix will not free the C++ memory when it is garbage collected.
The C++ memory will be freed by the finalizer.
"""
# This is the safe and robust way to create a Julia Matrix from C++ 'new'-allocated data
function copyMatrix(object::EigenMatrix)::Matrix{Cdouble} # Renaming to copyMatrix or similar might be clearer
    return copy(unsafe_wrap(Array, Base.unsafe_convert(Ptr{Cdouble}, data(object)),
        (rows(object), cols(object)); own = false))
end

"""
Returns the matrix as a Julia vector.

# Arguments
- `object::EigenMatrix`: the matrix

# Notes:
This is the safe and robust way to create a Julia Vector from C++ 'new'-allocated data
It does not transfer ownership of the data, so the Julia Vector will not free the C++ memory when it is garbage collected.
The C++ memory will be freed by the finalizer.

"""
function copyVector(object::EigenMatrix)::Vector{Cdouble}
    return copy(unsafe_wrap(Array, data(object), (rows(object)); own = false))
end

Base.deepcopy(obj::EigenMatrix) = EigenMatrix(rows(obj), cols(obj), data(obj))

function Base.show(io::IO, obj::EigenMatrix)
    ccall((:gsMatrix_print, libgismo), Cvoid, (Ptr{gsCMatrix},), obj.ptr)
end

"""
Sets all the elements of the matrix to zero.

# Arguments
- `object::EigenMatrix`: the matrix

"""
function setZero!(object::EigenMatrix)::Nothing
    ccall((:gsMatrix_setZero, libgismo), Cvoid, (Ptr{gsCMatrix},), object.ptr)
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
        m = new(ccall((:gsMatrixInt_create, libgismo), Ptr{gsCMatrixInt}, ()))
        finalizer(destroy!, m)
        return m
    end

    """
    Creates an empty matrix

    # Arguments
    - `r::Int`: the number of rows
    - `c::Int`: the number of columns
    """
    function EigenMatrixInt(r::Int, c::Int)
        m = new(ccall((:gsMatrixInt_create_rc, libgismo), Ptr{gsCMatrixInt},
            (Cint, Cint), r, c))
        finalizer(destroy!, m)
        return m
    end

    """
    Creates a matrix from a Julia matrix

    # Arguments
    - `M::Matrix{Cint}`: the matrix
    """
    function EigenMatrixInt(M::Matrix{Cint})
        m = new(ccall((:gsMatrixInt_create_rcd, libgismo), Ptr{gsCMatrixInt},
            (Cint, Cint, Ptr{Cint}), size(M, 1), size(M, 2), M))
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
    function EigenMatrixInt(r::Int, c::Int, data::Ptr{Cint})
        m = new(ccall((:gsMatrixInt_create_rcd, libgismo), Ptr{gsCMatrixInt},
            (Cint, Cint, Ptr{Cint}), r, c, data))
        finalizer(destroy!, m)
        return m
    end

    function destroy!(m::EigenMatrixInt)
        ccall((:gsMatrixInt_delete, libgismo), Cvoid, (Ptr{gsCMatrixInt},), m.ptr)
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
    return ccall((:gsMatrixInt_rows, libgismo), Cint, (Ptr{gsCMatrixInt},), object.ptr)
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
    return ccall((:gsMatrixInt_cols, libgismo), Cint, (Ptr{gsCMatrixInt},), object.ptr)
end

"""
Returns a pointer to the data of the matrix.

# Arguments
- `object::EigenMatrixInt`: the matrix

"""
function data(object::EigenMatrixInt)::Ptr{Cint}
    return ccall((:gsMatrixInt_data, libgismo), Ptr{Cint}, (Ptr{gsCMatrixInt},), object.ptr)
end

"""
Returns the matrix as a Julia matrix.

# Arguments
- `object::EigenMatrixInt`: the matrix

# Notes:
This is the safe and robust way to create a Julia Matrix from C++ 'new'-allocated data
It does not transfer ownership of the data, so the Julia Matrix will not free the C++ memory when it is garbage collected.
The C++ memory will be freed by the finalizer.

"""
function copyMatrix(object::EigenMatrixInt)::Matrix{Cint}
    return copy(unsafe_wrap(Array, Base.unsafe_convert(Ptr{Cint}, data(object)),
        (rows(object), cols(object)); own = false))
end

"""
Returns the matrix as a Julia vector.

# Arguments
- `object::EigenMatrixInt`: the matrix

# Notes:
This is the safe and robust way to create a Julia Vector from C++ 'new'-allocated data
It does not transfer ownership of the data, so the Julia Vector will not free the C++ memory when it is garbage collected.
The C++ memory will be freed by the finalizer.

"""
function copyVector(object::EigenMatrixInt)::Vector{Int}
    return copy(unsafe_wrap(Array, Base.unsafe_convert(Ptr{Cint}, data(object)),
        (rows(object), cols(object)); own = false))
end

Base.deepcopy(obj::EigenMatrixInt) = EigenMatrixInt(rows(obj), cols(obj), data(obj))

function Base.show(io::IO, obj::EigenMatrixInt)
    ccall((:gsMatrixInt_print, libgismo), Cvoid, (Ptr{gsCMatrixInt},), obj.ptr)
end

"""
Sets all the elements of the matrix to zero.

# Arguments
- `object::EigenMatrixInt`: the matrix

"""
function setZero!(object::EigenMatrixInt)::Nothing
    ccall((:gsMatrixInt_setZero, libgismo), Cvoid, (Ptr{gsCMatrixInt},), object.ptr)
end

########################################################################
# gsSparseMatrix
########################################################################

"""
    EigenSparseMatrix()

Creates an empty sparse matrix.

# Example

```jldoctest output=(false)
m = EigenSparseMatrix()
# output
```
"""
mutable struct EigenSparseMatrix
    ptr::Ptr{gsCSparseMatrix}

    """
    Creates an empty sparse matrix.
    """
    function EigenSparseMatrix()
        m = new(ccall((:gsSparseMatrix_create, libgismo), Ptr{gsCSparseMatrix}, ()))
        finalizer(destroy!, m)
        return m
    end

    """
    Creates a sparse matrix from triplets

    # Arguments
    - `rows::Vector{Cint}`: the row indices
    - `cols::Vector{Cint}`: the column indices
    - `vals::Vector{Cdouble}`: the values
    """
    function EigenSparseMatrix(
            rows::Vector{Cint}, cols::Vector{Cint}, vals::Vector{Cdouble})
        @assert length(rows) == length(cols) == length(vals) "EigenSparseMatrix: rows, cols and vals must have the same length"
        rows = rows .- Cint(1)
        cols = cols .- Cint(1)
        @assert all(rows .>= Cint(0)) "EigenSparseMatrix: rows must be greater or equal to 1"
        @assert all(cols .>= Cint(0)) "EigenSparseMatrix: cols must be greater or equal to 1"
        R = EigenMatrixInt(Base.size(rows, 1), 1, pointer(rows))
        C = EigenMatrixInt(Base.size(cols, 1), 1, pointer(cols))
        V = EigenMatrix(Base.size(vals, 1), 1, pointer(vals))
        m = new(ccall((:gsSparseMatrix_create, libgismo), Ptr{gsCSparseMatrix}, ()))
        ccall((:gsSparseMatrix_setFromTriplets, libgismo), Cvoid,
            (Ptr{gsCSparseMatrix}, Ptr{gsCMatrixInt}, Ptr{gsCMatrixInt}, Ptr{EigenMatrix}),
            m.ptr, R.ptr, C.ptr, V.ptr)
        finalizer(destroy!, m)
        return m
    end

    """
    Creates a sparse matrix from a Julia sparse matrix

    # Arguments
    - `matrix::SparseMatrixCSC{Cdouble,Cint}`: the matrix
    """
    function EigenSparseMatrix(matrix::SparseMatrixCSC{Cdouble, Cint})
        (rows, cols, vals) = SparseArrays.findnz(matrix)
        EigenSparseMatrix(rows, cols, vals)
    end

    """
    Creates a sparse matrix from a tuple of vectors

    # Arguments
    - `data::Tuple{Vector{Cint},Vector{Cint},Vector{Cdouble}}`: the data
    """
    function EigenSparseMatrix(data::Tuple{Vector{Cint}, Vector{Cint}, Vector{Cdouble}})
        (rows, cols, vals) = data
        EigenSparseMatrix(rows, cols, vals)
    end

    function destroy!(m::EigenSparseMatrix)
        ccall((:gsSparseMatrix_delete, libgismo), Cvoid, (Ptr{gsCSparseMatrix},), m.ptr)
    end
end

Base.deepcopy(obj::EigenSparseMatrix) = EigenSparseMatrix(findnz(obj))

function Base.show(io::IO, obj::EigenSparseMatrix)
    ccall((:gsSparseMatrix_print, libgismo), Cvoid, (Ptr{gsCSparseMatrix},), obj.ptr)
end

"""
Returns the number of rows in the matrix.

# Arguments
- `m::EigenSparseMatrix`: the matrix
"""
function rows(m::EigenSparseMatrix)::Int
    return ccall((:gsSparseMatrix_rows, libgismo), Cint, (Ptr{gsCSparseMatrix},), m.ptr)
end

"""
Returns the number of columns in the matrix.

# Arguments
- `m::EigenSparseMatrix`: the matrix
"""
function cols(m::EigenSparseMatrix)::Int
    return ccall((:gsSparseMatrix_cols, libgismo), Cint, (Ptr{gsCSparseMatrix},), m.ptr)
end

"""
Returns the number of non-zero elements in the matrix.

# Arguments
- `m::EigenSparseMatrix`: the matrix
"""
function nnz(m::EigenSparseMatrix)::Int
    return ccall((:gsSparseMatrix_nnz, libgismo), Cint, (Ptr{gsCSparseMatrix},), m.ptr)
end

function copyMatrix(m::EigenSparseMatrix)::SparseMatrixCSC{Cdouble, Cint}
    Nrows = rows(m)
    Ncols = cols(m)
    NNZ   = nnz(m)
    if Nrows == 0 || Ncols == 0 || NNZ == 0 # Handle empty or invalid matrix
        @warn "Eigen matrix appears empty or invalid (rows=$Nrows, cols=$Ncols, nnz=$NNZ)."
        return SparseMatrixCSC{Cdouble, Cint}(Nrows, Ncols, Int[], Int[], Float64[])
    end
    valuePtr = ccall(
        (:gsSparseMatrix_valuePtr, libgismo), Ptr{Cdouble}, (Ptr{gsCSparseMatrix},), m.ptr)
    innerIndexPtr = ccall((:gsSparseMatrix_innerIndexPtr, libgismo),
        Ptr{Cint}, (Ptr{gsCSparseMatrix},), m.ptr)
    outerIndexPtr = ccall((:gsSparseMatrix_outerIndexPtr, libgismo),
        Ptr{Cint}, (Ptr{gsCSparseMatrix},), m.ptr)
    nzval = copy(unsafe_wrap(Vector{Cdouble}, valuePtr, NNZ; own = false))
    # nzval = unsafe_wrap(Vector{Cdouble}, valuePtr, NNZ; own = false)
    rowIndices0 = unsafe_wrap(Vector{Cint}, innerIndexPtr, NNZ; own = false)
    rowIndices = Vector{Int}(undef, NNZ)
    @. rowIndices .= rowIndices0 .+ 1 # Convert to 1-based indexing
    colIndices0 = unsafe_wrap(Vector{Cint}, outerIndexPtr, Ncols + 1; own = false)
    colIndices = Vector{Int}(undef, Ncols + 1)
    @. colIndices .= colIndices0 .+ 1 # Convert to 1-based indexing
    return SparseMatrixCSC{Cdouble, Int}(Nrows, Ncols, colIndices, rowIndices, nzval)
end
