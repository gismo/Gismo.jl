export
    OptionList,
    destroy!,
    show,
    addString,
    addInt,
    addSwitch,
    addReal,
    getString,
    getInt,
    getSwitch,
    getReal,
    setString,
    setInt,
    setSwitch,
    setReal
    #= TODO =#

########################################################################
# gsOptionList
########################################################################

"""
A struct that represents a list of options
"""
mutable struct OptionList
    ptr::Ptr{gsCOptionList}

    function OptionList(opt::Ptr{gsCOptionList},delete::Bool=true)
        b = new(opt)
        if (delete)
            finalizer(destroy!,b)
        end
        return b
    end

    """
    Create an empty option list

    # Examples
    ```jldoctest output=(false)
    opt = OptionList()
    # output
    ```
    """
    function OptionList()
        opt = ccall((:gsOptionList_create,libgismo),Ptr{gsCOptionList},(),)
        return OptionList(opt)
    end

    """
    Create an option list from a dictionary

    # Arguments
    - `options::Dict`: a dictionary with the options

    # Examples
    ```jldoctest output=(false)
    options = Dict("key1"=>"value1","key2"=>2,"key3"=>3.0,"key4"=>true)
    opt = OptionList(options)
    # output
    ```
    """
    function OptionList(options::Dict)
        opt = ccall((:gsOptionList_create,libgismo),Ptr{gsCOptionList},(),)
        # Empty string
        desc::String = ""
        for (key,value) in options
            if (typeof(value) == String)
                ccall((:gsOptionList_addString,libgismo),Cvoid,(Ptr{gsCOptionList},Cstring,Cstring,Cstring),opt,key,desc,value)
            elseif (typeof(value) == Int)
                ccall((:gsOptionList_addInt,libgismo),Cvoid,(Ptr{gsCOptionList},Cstring,Cstring,Cint),opt,key,desc,value)
            elseif (typeof(value) == Float64)
                ccall((:gsOptionList_addReal,libgismo),Cvoid,(Ptr{gsCOptionList},Cstring,Cstring,Cdouble),opt,key,desc,value)
            elseif (typeof(value) == Bool)
                ccall((:gsOptionList_addSwitch,libgismo),Cvoid,(Ptr{gsCOptionList},Cstring,Cstring,Cint),opt,key,desc,Int(value))
            else
                error("OptionList: Unsupported type for value")
            end
        end
        return OptionList(opt)
    end

    function destroy!(opt::OptionList)
        ccall((:gsOptionList_delete,libgismo),Cvoid,(Ptr{gsCOptionList},),opt.ptr)
    end
end

Base.show(io::IO, obj::OptionList) = ccall((:gsOptionList_print,libgismo),Cvoid,(Ptr{gsCOptionList},),obj.ptr)

# Adders
"""
Add a string to the option list

# Arguments
- `opt::OptionList`: the option list
- `key::String`: the key
- `string::String`: the value
- `desc::String`: the description

# Examples
```jldoctest output=(false)
opt = OptionList()
addString(opt,"key","value","description")
# output
```
"""
function addString(opt::OptionList,key::String,string::String,desc::String="")
    ccall((:gsOptionList_addString,libgismo),Cvoid,(Ptr{gsCOptionList},Cstring,Cstring,Cstring),opt.ptr,key,desc,string)
end

"""
Add an integer to the option list

# Arguments
- `opt::OptionList`: the option list
- `key::String`: the key
- `int::Int`: the value
- `desc::String`: the description

# Examples
```jldoctest output=(false)
opt = OptionList()
addInt(opt,"key",1,"description")
# output
```
"""
function addInt(opt::OptionList,key::String,int::Int,desc::String="")
    ccall((:gsOptionList_addInt,libgismo),Cvoid,(Ptr{gsCOptionList},Cstring,Cstring,Cint),opt.ptr,key,desc,int)
end

"""
Add a real to the option list

# Arguments
- `opt::OptionList`: the option list
- `key::String`: the key
- `real::Cdouble`: the value
- `desc::String`: the description

# Examples
```jldoctest output=(false)
opt = OptionList()
addReal(opt,"key",1.0,"description")
# output
```
"""
function addReal(opt::OptionList,key::String,real::Cdouble,desc::String="")
    ccall((:gsOptionList_addReal,libgismo),Cvoid,(Ptr{gsCOptionList},Cstring,Cstring,Cdouble),opt.ptr,key,desc,real)
end

"""
Add a switch to the option list

# Arguments
- `opt::OptionList`: the option list
- `key::String`: the key
- `switch::Bool`: the value
- `desc::String`: the description

# Examples
```jldoctest output=(false)
opt = OptionList()
addSwitch(opt,"key",true,"description")
# output
```
"""
function addSwitch(opt::OptionList,key::String,switch::Bool,desc::String="")
    ccall((:gsOptionList_addSwitch,libgismo),Cvoid,(Ptr{gsCOptionList},Cstring,Cstring,Cint),opt.ptr,key,desc,Cint(switch))
end

# Getters
"""
Get a string from the option list

# Arguments
- `opt::OptionList`: the option list
- `key::String`: the key

# Return
- `string::Cstring`: the value

!!! warning
    The returned value is a Cstring, and its conversion to a Julia string is not trivial.
"""
function getString(opt::OptionList,key::String)::Cstring
    return ccall((:gsOptionList_getString,libgismo),Cstring,(Ptr{gsCOptionList},Cstring),opt.ptr,key)
end

"""
Get an integer from the option list

# Arguments
- `opt::OptionList`: the option list
- `key::String`: the key

# Return
- `int::Int`: the value

# Examples
```jldoctest
opt = OptionList(Dict("key1"=>1))
println(getInt(opt,"key1"))
# output
1
```
"""
function getInt(opt::OptionList,key::String)::Int
    return ccall((:gsOptionList_getInt,libgismo),Cint,(Ptr{gsCOptionList},Cstring),opt.ptr,key)
end

"""
Get a real from the option list

# Arguments
- `opt::OptionList`: the option list
- `key::String`: the key

# Return
- `real::Cdouble`: the value

# Examples
```jldoctest
opt = OptionList(Dict("key1"=>1.0))
println(getReal(opt,"key1"))
# output
1.0
```
"""
function getReal(opt::OptionList,key::String)::Cdouble
    return ccall((:gsOptionList_getReal,libgismo),Cdouble,(Ptr{gsCOptionList},Cstring),opt.ptr,key)
end

"""
Get a switch from the option list

# Arguments
- `opt::OptionList`: the option list
- `key::String`: the key

# Return
- `switch::Bool`: the value

# Examples
```jldoctest
opt = OptionList(Dict("key1"=>true))
println(getSwitch(opt,"key1"))
# output
true
```
"""
function getSwitch(opt::OptionList,key::String)::Bool
    return ccall((:gsOptionList_getSwitch,libgismo),Cint,(Ptr{gsCOptionList},Cstring),opt.ptr,key)
end

# Setters
"""
Set a string to the option list

# Arguments
- `opt::OptionList`: the option list
- `key::String`: the key
- `string::String`: the value

# Examples
```jldoctest output=(false)
opt = OptionList(Dict("key"=>"value"))
setString(opt,"key","value")
# output
```
"""
function setString(opt::OptionList,key::String,string::String)
    try
        ccall((:gsOptionList_setString,libgismo),Cvoid,(Ptr{gsCOptionList},Cstring,Cstring),opt.ptr,key,string)
    catch
        error("OptionList: Key not found")
    end
end

"""
Set an integer to the option list

# Arguments
- `opt::OptionList`: the option list
- `key::String`: the key
- `int::Int`: the value

# Εxamples
```jldoctest output=(false)
opt = OptionList(Dict("key"=>1))
setInt(opt,"key",2)
# output
```
"""
function setInt(opt::OptionList,key::String,int::Int)
    ccall((:gsOptionList_setInt,libgismo),Cvoid,(Ptr{gsCOptionList},Cstring,Cint),opt.ptr,key,int)
end

"""
Set a real to the option list

# Arguments
- `opt::OptionList`: the option list
- `key::String`: the key
- `real::Cdouble`: the value

# Examples
```jldoctest output=(false)
opt = OptionList(Dict("key"=>1.0))
setReal(opt,"key",2.0)
# output
```
"""
function setReal(opt::OptionList,key::String,real::Cdouble)
    ccall((:gsOptionList_setReal,libgismo),Cvoid,(Ptr{gsCOptionList},Cstring,Cdouble),opt.ptr,key,real)
end

"""
Set a switch to the option list

# Arguments
- `opt::OptionList`: the option list
- `key::String`: the key
- `switch::Bool`: the value

# Examples
```jldoctest output=(false)
opt = OptionList(Dict("key"=>true))
setSwitch(opt,"key",false)
# output
```
"""
function setSwitch(opt::OptionList,key::String,switch::Bool)
    ccall((:gsOptionList_setSwitch,libgismo),Cvoid,(Ptr{gsCOptionList},Cstring,Cint),opt.ptr,key,Cint(switch))
end