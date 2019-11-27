
struct ExternalFieldFlow{N,T} <: AbstractFlowDynamics
    g::SVector{N,T}
end


function collision_time(b::MovableBall, Π::FixedPlane, flow::ExternalFieldFlow)

    @unpack r, x, v = b
    @unpack n, p = Π
    g = flow.g

    a = g ⋅ n
    b = v ⋅ n
    c = 2 * ( (x - p) ⋅ n + r )

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


"Collision time for moving balls is independent of constant external field."
collision_time(b1::MovableBall, b2::MovableBall, ::ExternalFieldFlow) =
    collision_time(b1, b2, FreeFlow())



"Flow ball for a time t"
function flow!(b::MovableBall, t, flow::ExternalFieldFlow)
    g = flow.g

    b.x += b.v * t + 0.5*g*t^2
    b.v += flow_type.g * t
end
