# `HardSphereDynamics.jl`

Julia package to simulate the dynamics of hard sphere fluids in any number of dimensions via an event-driven algorithm.


## Usage

```julia

using HardSphereDynamics

d = 3
n = 100   # number of spheres
r = 0.05  # radius

δt = 0.01
final_time = 10

fluid = HardSphereFluid(d, n, r)  # create hard spheres in unit box in d dimensions

num_collisions = 100
pos, vel, times, types = evolve!(fluid, num_collisions)  # return data at each collision

pos, vel, times = evolve!(fluid, δt, final_time)  # return data at given times
```

Each version of `evolve!` returns a `Vector` of positions and a `Vector` of velocities of each sphere at the given collisions or times. The collision version also returns a vector of collision types.

There are examples of visualizing the results using `Makie.jl` in 2D and 3D in the `examples` directory
(but no dependency on `Makie.jl` is assumed).

The spheres may have different radii and masses. Currently they must live in a hard rectangular box, by default a unit cube, but this is relatively easy to improve.

## Author

- [David P. Sanders](http://sistemas.fciencias.unam.mx/~dsanders), Departamento de Física, Facultad de Ciencias, Universidad Nacional Autónoma de México (UNAM) & Visiting researcher, MIT



## Acknowledgements

Financial support is acknowledged from DGAPA-UNAM PAPIIT grant IN-117117 and a *Cátedra Marcos Moshinsky* (2018).

The author thanks Simon Danisch for help with visualizations using `Makie.jl`.
