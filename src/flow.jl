abstract type AbstractFlowDynamics end


function flow!(balls::Vector{<:MovableBall}, t, flow_type::AbstractFlowDynamics)
	for ball in balls
		flow!(ball, t, flow_type)
	end
end
