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
positions, velocities, times = time_evolution!(fluid, δt, final_time)
```

There are examples of visualizing the results using `Makie.jl` in the `examples` directory
(but no dependency on `Makie.jl` is assumed).

## Author

- [David P. Sanders](http://sistemas.fciencias.unam.mx/~dsanders), Departamento de Física, Facultad de Ciencias, Universidad Nacional Autónoma de México (UNAM) & Visiting researcher, MIT



## Acknowledgements

Financial support is acknowledged from DGAPA-UNAM PAPIIT grant IN-117117 and a *Cátedra Marcos Moshinsky* (2018).

The author thanks Simon Danisch for help with visualizations using `Makie.jl`.
