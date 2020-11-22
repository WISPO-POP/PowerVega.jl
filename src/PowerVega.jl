module PowerVega

import InfrastructureModels
import PowerModels
using Statistics, LightGraphs



using VegaLite, VegaDatasets
using DataFrames
using JSON
using FilePaths

import PyCall
const nx = PyCall.PyNULL()
const scipy = PyCall.PyNULL()

function __init__()
    copy!(nx, PyCall.pyimport_conda("networkx", "networkx"))
    copy!(scipy, PyCall.pyimport_conda("scipy", "scipy"))
end


include("core/data.jl")
include("core/layout.jl")
include("core/plot.jl")


include("core/export.jl")  # must be last to properly export all functions


end # module
