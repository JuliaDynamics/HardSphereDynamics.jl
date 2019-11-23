abstract type AbstractFlowDynamics end

struct FreeFlow <: AbstractFlowDynamics end



function collision_time(b::MovableBall, Π::FixedPlane, ::FreeFlow)
    @unpack r, x, v = b
    @unpack n, p = Π

    if v ⋅ n < 0  # travelling in wrong direction
        return Inf
    end

    return (-r - (x - p)⋅n) / (v ⋅ n)
end



function collision_time(b1::MovableBall, b2::MovableBall, ::FreeFlow)
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




function find_collision(b::MovableBall{N,T}, box::RectangularBox{N,T}, ::FreeFlow) where {N,T}

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




"Flow ball for a time t"
function flow!(b::MovableBall, t, ::FreeFlow)
    b.x += b.v * t
end
