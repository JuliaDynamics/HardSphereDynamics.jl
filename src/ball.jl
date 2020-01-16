

"Movable ball in N dimensions"
mutable struct MovableBall{N,T,S}
    x::SVector{N,T}  # position of centre
    v::SVector{N,T}  # velocity
    r::S             # radius
    m::S             # mass
end

MovableBall(x, v, r) = MovableBall(x, v, r, one(r))

centre(b::MovableBall) = b.x

"Normal vector at point x on sphere"
normal(b::MovableBall, x) = normalize(x - centre(b))
