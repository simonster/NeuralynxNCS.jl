# NeuralynxNCS

[![Build Status](https://travis-ci.org/simonster/NeuralynxNCS.jl.svg?branch=master)](https://travis-ci.org/simonster/NeuralynxNCS.jl)
[![Coverage Status](https://coveralls.io/repos/simonster/NeuralynxNCS.jl/badge.svg?branch=master)](https://coveralls.io/r/simonster/NeuralynxNCS.jl?branch=master)

This is a Julia module for reading Neuralynx NCS files. You can read files as:

```julia
readncs("CSC1.Ncs")
```

The output is an object:

```julia
immutable NCSContinuousChannel
    header::ByteString
    samples::Vector{Int16}
    times::PiecewiseIncreasingRange{Float64,StepRange{Int64,Int64},Int64}
end
```

At present it supports only a single channel per file, because this is
how all the NCS files I have are structured. 

See [PiecewiseIncreasingRanges.jl](https://github.com/simonster/PiecewiseIncreasingRanges.jl)
for some more information on how to use `times`.
