using Gismo

options = Dict([("a",1), ("b",1.1), ("c", true), ("d", "one")])
println(options)
gsOptionList = OptionList(options)
println(gsOptionList)

Gismo.setInt(gsOptionList,"a",2)
Gismo.setReal(gsOptionList,"b",2.0)
Gismo.setSwitch(gsOptionList,"c",false)
Gismo.setString(gsOptionList,"d","two")
println(gsOptionList)

int::Int = Gismo.getInt(gsOptionList,"a")
println("Integer read from option list: ",int)
double::Float64 = Gismo.getReal(gsOptionList,"b")
println("Double read from option list: ",double)
bool::Bool = Gismo.getSwitch(gsOptionList,"c")
println("Bool read from option list: ",bool)
string::Cstring = Gismo.getString(gsOptionList,"d")
println("String read from option list: ",string)