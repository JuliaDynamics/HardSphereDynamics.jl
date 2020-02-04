
"""
	FixedPlane{N,T}

Fixed `N`-dimensional hyperplane.

- `p`: point on the plane
- `n`: normal vector
"""
struct FixedPlane{N,T}
    p::SVector{N,T}
    n::SVector{N,T}
end

normal(p::FixedPlane, x) = p.n

abstract type Table{N,T} end  # billiard table

"""
"Rectangular" box in N dimensions.

`lower` and `upper` contain the lower and upper bounds in each dimension.
"""
struct RectangularBox{N,T} <: Table{N,T}
    lower::SVector{N,T}
    upper::SVector{N,T}
    walls::Vector{FixedPlane{N,T}}

    function RectangularBox{N,T}(lower::SVector{N,T}, upper::SVector{N,T}) where {N,T}

        z = zero(SVector{N,T})

        walls = FixedPlane{N,T}[]

        for i in 1:N
            n = setindex(z, -1, i)  # unit vector with one non-zero component

            push!(walls, FixedPlane(lower, n))
            push!(walls, FixedPlane(upper, -n))
        end

        new{N,T}(lower, upper, walls)
    end
end

RectangularBox(lower::SVector{N,T}, upper::SVector{N,T}) where {N,T} = RectangularBox{N,T}(lower, upper)


function unit_hypercube(N, T)
	return RectangularBox(-0.5 .* ones(SVector{N,T}),
						  +0.5 .* ones(SVector{N,T})
						  )
end
