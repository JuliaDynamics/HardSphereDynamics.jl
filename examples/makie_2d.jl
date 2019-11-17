include("hard_sphere_fluid.jl")


# fluid = HardSphereFluid{2,Float64}(500, 0.01)

fluid = HardSphereFluid{2,Float64}(100, 0.02)
positions, velocities = time_evolution!(fluid, 0.001, 10)


using Makie
using GeometryTypes
using AbstractPlotting

scene = Scene(resolution = (1000, 1000));


data = Makie.Node(Point2f0.(positions[1]))

limits = FRect(0.0, 0.0, 1.0, 1.0)


cs = Makie.Node(norm.(Point2f0.(velocities[1])))

s = Makie.scatter!(scene, data, color=cs, colormap=:viridis, markersize=2f0.*Float32[fluid.balls[n].r for n in 1:length(fluid.balls)], limits=limits);
# markersize is diameter not radius

# data[] = Point2f0.(positions[2])

scene

for n in 1:length(positions)
    data[] = Point2f0.(positions[n])
    cs[] = norm.(Point2f0.(velocities[n]))
    sleep(0.0001)
end
