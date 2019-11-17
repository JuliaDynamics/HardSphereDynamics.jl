include("hard_sphere_fluid.jl")


#fluid = HardSphereFluid{3,Float64}(100, 0.05)


using Makie
using GeometryTypes
using AbstractPlotting
using Colors



# fluid = HardSphereFluid{3,Float64}(2, 0.28)
# fluid = HardSphereFluid{3, Float64}(100, 0.05)

# @time positions, velocities, times = time_evolution!(fluid, 0.01, 100)


#c = Circle(Point2f0(positions[1][1]), 50f0)
#poly!(scene, c)



# cs = collect(Iterators.take(Iterators.cycle(distinguishable_colors(5)), length(fluid.balls)));

cs = Makie.Node(norm.(Point3f0.(velocities[1])))

# cs = [RGBA(c.r, c.g, c.b, 0.8) for c in cs]


limits = FRect3D(Point3f0(0.0f0, 0.0f0, 0.0f0), Point3f0(1.0f0, 1.0f0, 1.0f0))

mean_c = mean(cs[])

cs[]

crange = (0, 2 * mean_c)

data = Makie.Node(Point3f0.(positions[1]))

scene = Scene(resolution = (1000, 1000))
s = Makie.meshscatter!(scene, data, color=cs, colorrange=crange, colormap=:viridis, markersize=Float32[fluid.balls[n].r for n in 1:length(fluid.balls)], limits=limits)
# , transparency=true,


for n in 1:length(positions)
    data[] = Point3f0.(positions[n])
    cs[] = norm.(Point3f0.(velocities[n]))
    sleep(0.001)
end



function run_simulation(n=2, r=0.28, final_time=1000, sleep_step=0.001)
    fluid = HardSphereFluid{3,Float64}(n, r)

    positions, velocities, times = time_evolution!(fluid, 0.01, final_time)

    cs = Makie.Node(norm.(Point3f0.(velocities[1])))

    limits = FRect3D(Point3f0(0.0f0, 0.0f0, 0.0f0), Point3f0(1.0f0, 1.0f0, 1.0f0))
    mean_c = mean(cs[])

    crange = (0, 2 * mean_c)

    data = Makie.Node(Point3f0.(positions[1]))

    scene = Scene(resolution = (1000, 1000))
    s = Makie.meshscatter!(scene, data, color=cs, colorrange=crange, colormap=:viridis, markersize=Float32[fluid.balls[n].r for n in 1:length(fluid.balls)], limits=limits)
    # , transparency=true,

    display(s)


    for n in 1:length(positions)
        data[] = Point3f0.(positions[n])
        cs[] = norm.(Point3f0.(velocities[n]))
        sleep(sleep_step)
    end

    return positions, velocities, times

end

# run_simulation()

positions, velocities, times = run_simulation(10, 0.1, 100)
