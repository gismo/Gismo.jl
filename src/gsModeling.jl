export
    Fitting,
    destroy!,
    compute!,
    parameterCorrection!,
    computeErrors!,
    minPointError,
    maxPointError,
    pointWiseErrors,
    numPointsBelow,
    result
    #= TODO =#

########################################################################
# gsFitting
########################################################################

"""
 Creates a fitting structure
"""
mutable struct Fitting
    ptr::Ptr{gsCFitting}

    """
    Fitting(opt::Ptr{gsCFitting},delete:Bool)

    # Arguments
    - `opt::Ptr{gsCFitting}`: A pointer to a gsCFiting object
    - `delete::Bool`: Whether to destroy the fitting structure when unused

    """
    function Fitting(opt::Ptr{gsCFitting},delete::Bool=true)::Fitting
        b = new(opt)
        if (delete)
            finalizer(destroy!,b)
        end
        return b
    end

    """
    Fitting(parValues::Matrix{Cdouble}, pts::Matrix{Cdouble}, basis::Basis)::Fitting

    # Arguments
    - `parValues::Matrix{Cdouble}`: a matrix containing the parameters values
    - `pts::Matrix{Cdouble}`: a matrix of points
    - `basis::Basis`: a Basis structure containing the desired basis

    """
    function Fitting(parValues::AbstractMatrix{Cdouble}, pts::AbstractMatrix{Cdouble}, basis::Basis)::Fitting
        @assert Base.size(parValues,2) == Base.size(pts,2) "Fitting: parValues and points must have the same number of columns"
        param_values = EigenMatrix(Base.size(parValues,1),Base.size(parValues,2),pointer(parValues))
        points = EigenMatrix(Base.size(pts,1),Base.size(pts,2),pointer(pts))
        fitter = ccall((:gsFitting_create,libgismo),Ptr{gsCFitting},(Ptr{EigenMatrix},Ptr{EigenMatrix},Ptr{gsCBasis}),param_values.ptr,points.ptr,basis.ptr)
        return Fitting(fitter)
    end

    function destroy!(fit::Fitting)
        ccall((:gsFitting_delete,libgismo),Cvoid,(Ptr{gsCFitting},),fit.ptr)
    end
end


"""
compute!(fit::Fitting, lambda::Cdouble=0.0)
Computes the least squares fit

# Arguments
- `fit::Fitting`: a fitting structure
- `lambda::Cdouble`: the value to assign to the lambda ridge parameter

"""
function compute!(fit::Fitting, lambda::Cdouble=0.0)
    ccall((:gsFitting_compute,libgismo),Cvoid,(Ptr{gsCFitting},Cdouble),fit.ptr,lambda)
end

"""
parameterCorrection!(fit::Fitting, accuracy::Cdouble, maxIter::Int, tol0rth::Cdouble)
Performs the parameters corrections step

# Arguments
- `fit::Fitting`: a fitting structure
- `accuracy::Cdouble`: The desired accuracy
- `maxIter::Int`: The desired number of iterations
- `tol0rth::Cdouble`: The desired value of the tolleance

"""
function parameterCorrection!(fit::Fitting, accuracy::Cdouble=1.0, maxIter::Int=Int(10), tol0rth::Cdouble=1e-6)
    @assert maxIter >= 0 "Fitting: cannot have a negative number of iterations!"
    @assert accuracy >= 0 "Fitting: cannot have a negative accuracy!"
    ccall((:gsFitting_parameterCorrection,libgismo),Cvoid,(Ptr{gsCFitting},Cdouble,Cint,Cdouble),fit.ptr,accuracy,maxIter,tol0rth)
end

"""
computeErrors!(fit::Fitting)
Computes the error for each point

# Arguments
- `fit::Fitting`: a fitting structure

"""
function computeErrors!(fit::Fitting)
    ccall((:gsFitting_computeErrors,libgismo),Cvoid,(Ptr{gsCFitting},),fit.ptr)
end

"""
minPointError(fit::Fitting)::Cdouble
Returns the smallest error obtained between all the points

# Arguments
- `fit::Fitting`: a fitting structure
# Return
- `min_error::Cdouble`: The minimum error obtained

"""
function minPointError(fit::Fitting)::Cdouble
    min_error=ccall((:gsFitting_minPointError,libgismo),Cdouble,(Ptr{gsCFitting},),fit.ptr)
    return min_error
end

"""
maxPointError(fit::Fitting)::Cdouble
Returns the maximum error obtained

# Arguments
- `fit::Fitting`: a fitting structure
# Return
- `max_error::Cdouble`: The maximum error obtained

"""
function maxPointError(fit::Fitting)::Cdouble
    max_err=ccall((:gsFitting_maxPointError,libgismo),Cdouble,(Ptr{gsCFitting},),fit.ptr)
    return max_err
end

"""
pointWiseErrors(fit::Fitting)::Ptr{Cdouble}
Returns the error obtained for each point

# Arguments
- `fit::Fitting`: a fitting structure

# Return
- `errors::Ptr{Cdouble}`: Pointer pointing to an array containing the error value for each point

"""
function pointWiseErrors(fit::Fitting)::Ptr{Cdouble}
    errors=ccall((:gsFitting_pointWiseErrors,libgismo),Ptr{Cdouble},(Ptr{gsCFitting},),fit.ptr)
    return errors
end

"""
numPointsBelow(fit::Fitting, threshold::Cdouble)::Int
Returns the number of points where the error is below the threshold

# Arguments
- `fit::Fitting`: a fitting structure
- `threshold::Cdouble`: The desired threshold

# Return
- `number_pts_blw::Int`: number of points where the error is below the given threshold

"""
function numPointsBelow(fit::Fitting, threshold::Cdouble)::Int
    @assert threshold >= 0 "The threshold must be a positive real number!"
    number_pts_blw=ccall((:gsFitting_numPointsBelow,libgismo),Cint,(Ptr{gsCFitting},Cdouble),fit.ptr,threshold)
    return number_pts_blw
end

"""
result(fit::Fitting)::Geometry
Returns a geometry from the fitting structure

# Arguments
- `fit::Fitting`: a fitting structure

# Return
- `geom::Geometry`: the desired geometry

"""
function result(fit::Fitting)::Geometry
    geom = ccall((:gsFitting_result,libgismo),Ptr{gsCGeometry},(Ptr{gsCFitting},),fit.ptr)
    return Geometry(geom)
end