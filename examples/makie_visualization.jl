using HardSphereDynamics

using Makie
using GeometryTypes
using AbstractPlotting
using Colors
using StatsBase

using LinearAlgebra



function visualize_2d(fluid, positions, velocities, times, sleep_step=0.001)

    data = Makie.Node(Point2f0.(positions[1]))
    # limits = FRect2D(fluid.box.lower, fluid.box.upper)
    limits = FRect(0.0f0, 0.0f0, 1.0f0, 1.0f0)

    # color by speed:
    cs = Makie.Node(norm.(velocities[1]))
    mean_c = mean(cs[])
    crange = (0.0, 2 * mean_c)


    scene = Scene(resolution = (1000, 1000))
    s = Makie.scatter!(scene, data, marker=Circle(Point2f0(0), 10.0f0),
                            color=cs, colorrange=crange, colormap=:viridis,
                            markersize=[ball.r for ball in fluid.balls],
                            limits=limits)

    display(s)

    # update positions and velocities to animate:
    for t in 1:length(positions)
        data[] = positions[t]
        cs[] = norm.(velocities[t])
        sleep(sleep_step)
    end

end

function visualize_3d(fluid, positions, velocities, times, sleep_step=0.001)

    data = Makie.Node(Point3f0.(positions[1]))
    limits = FRect3D(fluid.box.lower, fluid.box.upper)

    # color by speed:
    cs = Makie.Node(norm.(velocities[1]))
    mean_c = mean(cs[])
    crange = (0.0, 2 * mean_c)


    scene = Scene(resolution = (1000, 1000))
    s = Makie.meshscatter!(scene, data,
                            color=cs, colorrange=crange, colormap=:viridis,
                            markersize=[ball.r for ball in fluid.balls],
                            limits=limits)

    display(s)

    # update positions and velocities to animagte:
    for t in 1:length(positions)
        data[] = positions[t]
        cs[] = norm.(velocities[t])
        sleep(sleep_step)
    end

end

## Run:

d = 3
n = 200   # number of spheres
r = 0.05  # radius

δt = 0.01
final_time = 100

fluid = HardSphereFluid(d, n, r)  # create hard spheres in unit box in d dimensions
positions, velocities, times = time_evolution!(fluid, δt, final_time)

visualize_3d(fluid, positions, velocities, times)


## Maxwell--Boltzmann distribution:
# using Plots
# Plots.histogram(reduce(vcat, [norm.(v) for v in velocities]), normed=true)
