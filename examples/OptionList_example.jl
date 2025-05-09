using Gismo

options = Dict([("a",1), ("b",1.1), ("c", true), ("d", "one")])
println(options)
gsOptionList = OptionList(options)
println(gsOptionList)

setInt(gsOptionList,"a",2)
setReal(gsOptionList,"b",2.0)
setSwitch(gsOptionList,"c",false)
setString(gsOptionList,"d","two")
println(gsOptionList)

int::Int = getInt(gsOptionList,"a")
println("Integer read from option list: ",int)
double::Float64 = getReal(gsOptionList,"b")
println("Double read from option list: ",double)
bool::Bool = getSwitch(gsOptionList,"c")
println("Bool read from option list: ",bool)
string::Cstring = getString(gsOptionList,"d")
println("String read from option list: ",string)