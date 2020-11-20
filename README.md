# PowerVega

[![Build Status](https://travis-ci.com/WISPO-POP/PowerPlots.jl.svg?branch=master)](https://travis-ci.com/WISPO-POP/PowerVega.jl)
[![Codecov](https://codecov.io/gh/WISPO-POP/PowerPlots.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/WISPO-POP/PowerVega.jl)

Tools for the analysis and visualization of PowerModels data and results.

BETA / IN ACTIVE DEVELOPMENT: Features will change quickly and without warning

## Adding PowerVega
`PowerVega` is not a registered julia package, but it can still be added by calling

```julia
Pkg> add https://github.com/WISPO-POP/PowerVega.jl.git
```

## Using PowerVega

The basic plot function for `PowerVega` is `plot_network()` which plots a  PowerModels network case.

```julia
using PowerVega
plot_network(network_case)
```

The function `plot_network!()` will plot the network on the active plot.
