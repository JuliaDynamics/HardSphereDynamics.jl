# HardSphereDynamics.jl

This is a Julia package to simulate the dynamics of hard-sphere fluids using an event-driven algorithm ("exact" calculation of each collision). The code is designed to work in any number of spatial dimensions.

Simple visualizations in 2D and 3D using Makie are also provided.


## Example usage

The following is with the as-yet-unreleased `master` branch:

```julia

using HardSphereDynamics, StaticArrays

# create box:

table = HardSphereDynamics.RectangularBox(SA[-0.5, -0.5, -1.0],
                                          SA[+0.5, +0.5, +3.0])

# create fluid:
d = 3     # spatial dimension
n = 20   # number of spheres
r = 0.1  # radius

fluid = HardSphereFluid{d,Float64}(table, n, r)
initial_condition!(fluid, lower=table.lower, upper=-table.lower)

# set up simulation:
collision_type = ElasticCollision()
flow_type = ExternalFieldFlow(SA[0.0, 0.0, -10.0])
event_handler = AllToAll(fluid, flow_type)

simulation =  HardSphereSimulation(
    fluid, event_handler, flow_type, collision_type);

# time evolution:
δt = 0.01
final_time = 100
states, times = evolve!(simulation, δt, final_time);

# visualization:
using Makie

visualize_3d(states, sleep_step=0.005, lower=table.lower, upper=-table.lower)
```




## Author

- [David P. Sanders](http://sistemas.fciencias.unam.mx/~dsanders), Departamento de Física, Facultad de Ciencias, Universidad Nacional Autónoma de México (UNAM) & Visiting researcher, MIT



## Acknowledgements

Financial support is acknowledged from DGAPA-UNAM PAPIIT grant IN-117117 and a *Cátedra Marcos Moshinsky* (2018).

The author thanks Simon Danisch for help with visualizations using `Makie.jl`.
