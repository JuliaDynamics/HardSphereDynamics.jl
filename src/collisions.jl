
function collision_time(b::MovableBall, Π::FixedPlane)
    @unpack r, x, v = b
    @unpack n, p = Π

    if v ⋅ n < 0  # travelling in wrong direction
        return Inf
    end

    return (-r - (x - p)⋅n) / (v ⋅ n)
end



function collision(b::MovableBall{N,T}, box::RectangularBox{N,T}) where {N,T}

    walls = box.walls

    tol = 1e-10

    min_collision_time = Inf
    which = -1

    for i in 1:length(walls)
        t = collision_time(b, walls[i])
        if tol < t < min_collision_time
            min_collision_time = t
            which = i
        end
    end

    return (which, min_collision_time)
end




"Elastic collision of ball with FixedPlane.
The ball is assumed to be touching the FixedPlane."
function collide!(b::MovableBall{N,T}, Π::FixedPlane{N,T}) where {N,T}
    v = b.v
    n = Π.n

    b.v = v - 2 * (v⋅n) * n
end


function collision_time(b1::MovableBall, b2::MovableBall)
    Δx = b1.x - b2.x
    Δv = b1.v - b2.v

    b = Δx⋅Δv

    if b > 0   # moving away
        return Inf
    end


    a = normsq(Δv)
    c = normsq(Δx) - (b1.r + b2.r)^2

    discriminant = b^2 - a*c

    if discriminant ≥ 0
        d = √discriminant

        # t1 = (-b + d) / a
        t2 = (-b - d) / a

        if t2 > 0
            return t2
        end
    end

    return Inf   # no collision
end

"Assumes b1 and b2 are touching"
function collide!(b1::MovableBall, b2::MovableBall)
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
