using HardSphereDynamics
include("makie_visualization.jl")

fluid = HardSphereFluid(1, 10, 0.03)  # create hard spheres in 1D
positions, velocities, times = evolve!(fluid, δt, final_time)

positions2 =  HardSphereDynamics.to_3D(positions)
velocities2 = HardSphereDynamics.to_3D(velocities)

visualize_3d(positions2, velocities2, [ball.r for ball in fluid.balls], sleep_step=0.01)
