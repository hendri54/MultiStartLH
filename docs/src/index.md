```@meta
CurrentModule = MultiStartLH
```

# MultiStartLH

An implementation of the `TikTak` algorithm [Arnoud, Antoine, Fatih Guvenen, and Tatjana Kleineberg. 2019. “Benchmarking Global Optimizers.” Working Paper 26340. National Bureau of Economic Research. https://doi.org/10.3386/w26340.].

The user provides:

- a function that runs the local optimization for a given parameter vector. The expected signature is

   ```julia
   soln, fVal, exitFlag = local_opt(guess :: Vector{Float64})
   ```

- a `Vector{Vector{Float64}}` that contains the starting points to be evaluated. Each entry is a `guess` for `local_opt`.

- an `AbstractUpdateRule` that generates a new `guess` from the history of points computed so far and from the set of user provided starting points. `TikTakRule` is implemented in the package.

- a file path where the optimization history is stored; cf. [`History`](@ref).

Algorithm parameters:

* `maxHours`: the maximum number of hours to run the global optimizer.
* `fTol`: terminate when the last two `fVal` differ by less than `fTol`.

## History

The history of the optimization is stored in a user provided path in `JLD2` format. [`load_history`](@ref) is used to load the history object. It contains all starting points, terminal `fVal`s, and `exitFlag`s.

## API

```@index
```



```@autodocs
Modules = [MultiStartLH]
```

