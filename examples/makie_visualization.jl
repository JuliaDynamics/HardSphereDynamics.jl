using HardSphereDynamics

using Makie
using GeometryTypes
using AbstractPlotting
using Colors
using StatsBase
using StaticArrays

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

visualize_3d(fluid::HardSphereFluid, positions, velocities; sleep_step=0.001) =
    visualize_3d(positions, velocities, [ball.r for ball in fluid.balls], sleep_step=sleep_step)


function visualize_3d(positions, velocities, radii;
                   lower = -0.5*ones(SVector{3,Float32}),
                    upper = 0.5*ones(SVector{3,Float32}),
                    sleep_step=0.001)

    data = Makie.Node(Point3f0.(positions[1]))
    limits = FRect3D(lower, upper .- lower)  # 2nd argument are widths in each direction

    # color by speed:
    cs = Makie.Node(norm.(velocities[1]))
    mean_c = mean(cs[])
    crange = (0.0, 2 * mean_c)

    scene = Scene(resolution = (1000, 1000))
    s = Makie.meshscatter!(scene, data,
                            color=cs, colorrange=crange, colormap=:viridis,
                            markersize=radii,
                            limits=limits)

    display(s)

    # update positions and velocities to animagte:
    for t in 1:length(positions)
        data[] = positions[t]
        cs[] = norm.(velocities[t])
        sleep(sleep_step)
    end

end

to_2D(v::SVector{1,T}) where {T} = SVector(zero(T), v[1])
to_3D(v::SVector{1,T}) where {T} = SVector(zero(T), zero(T), v[1])
to_3D(v::SVector{2,T}) where {T} = SVector(zero(T), v[1], v[2])

to_2D(v::Vector{Vector{SVector{N,T}}}) where {N,T} = [to_2D.(x) for x in v]
to_3D(v::Vector{Vector{SVector{N,T}}}) where {N,T} = [to_3D.(x) for x in v]






## Run:

d = 3
n = 200   # number of spheres
r = 0.05  # radius

δt = 0.01
final_time = 100

fluid = HardSphereFluid(d, n, r)  # create hard spheres in unit box in d dimensions
positions, velocities, times = evolve!(fluid, δt, final_time)

visualize_3d(fluid, positions, velocities)


## Maxwell--Boltzmann distribution:
# using Plots
# Plots.histogram(reduce(vcat, [norm.(v) for v in velocities]), normed=true)
