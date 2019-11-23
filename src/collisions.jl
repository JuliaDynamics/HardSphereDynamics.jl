abstract type AbstractCollisionDynamics end

struct ElasticCollision <: AbstractCollisionDynamics end



"Elastic collision of ball with FixedPlane.
The ball is assumed to be touching the FixedPlane."
function collide!(b::MovableBall{N,T}, Π::FixedPlane{N,T}, ::ElasticCollision) where {N,T}
    v = b.v
    n = Π.n

    b.v = v - 2 * (v⋅n) * n
end


"Assumes b1 and b2 are touching"
function collide!(b1::MovableBall, b2::MovableBall, ::ElasticCollision)
    Δx = b1.x - b2.x

    # @show norm(Δx)

    v1 = b1.v
    v2 = b2.v

    m1 = b1.m
    m2 = b2.m

    # reference: https://en.wikipedia.org/wiki/Elastic_collision#Two-dimensional_collision_with_two_moving_objects

    # physics
    # split velocities into component along line joining ball centers, and
    # orthogonal component

    # Ortho component is unchanged by elastic collision (since impulse is applied in direction of sphere centers)

    n = normalize(Δx)

    # "normal" components of velocities:
    v1n = (v1 ⋅ n) * n
    v2n = (v2 ⋅ n) * n

    # treat terms m1 / (m1 + m2)  and m2 / (m1 + m2)
    # by dividing top and bottom by m1
    # This allows one of them to be Inf

    mass_ratio = (1 / ((m1 / m2) + 1))

    v1′ = v1 + 2 * mass_ratio * (v2n - v1n)
    v2′ = v2 + 2 * (1 - mass_ratio) * (v1n - v2n)

    b1.v = v1′
    b2.v = v2′

end
