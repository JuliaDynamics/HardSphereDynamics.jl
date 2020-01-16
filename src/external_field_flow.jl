"""
Flow in a constant external field `g`.
"""
struct ExternalFieldFlow{N,T} <: AbstractFlowDynamics
    g::SVector{N,T}
end


function collision_time(ball::MovableBall{N}, Π::FixedPlane{N}, flow::ExternalFieldFlow{N}) where {N}

    @unpack r, x, v = ball
    @unpack n, p = Π
    g = flow.g

    b = v ⋅ n


    a = 0.5 * g ⋅ n

    if a == 0   # no effect of field
        return collision_time(ball, Π, FreeFlow())
    end

    c = (x - p) ⋅ n + r

    discriminant = b^2 - 4*a*c

    if discriminant ≥ 0
        d = √discriminant

        t1 = (-b - d) / (2a)
        t2 = (-b + d) / (2a)

        ## TODO: EXCLUDE CASE WHERE t1 IS BASICALLY 0 SINCE TOUCHING PLANE RIGHT NOW


        if t1 > 0 && (v + g*t1) ⋅ n > 0   # if b < 0, moving wrong way so exclude first bounce
            return t1
        end

        if t2 > 0 && (v + g*t2) ⋅ n > 0
            return t2
        end
    end

    return Inf   # no collision
end


"Collision time for moving balls is independent of constant external field."
collision_time(b1::MovableBall{N}, b2::MovableBall{N}, ::ExternalFieldFlow{N}) where {N} =
    collision_time(b1, b2, FreeFlow())



"Flow ball for a time t"
function flow!(b::MovableBall{N}, t, flow::ExternalFieldFlow{N}) where {N}
    g = flow.g

    b.x += b.v * t + 0.5*g*t^2
    b.v += g * t

    return b
end
