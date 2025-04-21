# src/backends/abstract_backend.jl

"""
    fit(backend::AbstractSBCBackend, generated)

Fit a model using the given backend to the generated data.
"""
function fit(backend::AbstractSBCBackend, generated)
    error("fit not implemented for backend type $(typeof(backend))")
end

"""
    draws_matrix(fit_result)

Convert a fit result to a draws matrix format.
"""
function draws_matrix(fit_result)
    error("draws_matrix not implemented for fit result type $(typeof(fit_result))")
end

"""
    iid_draws(backend::AbstractSBCBackend)

Return true if the backend produces independent and identically distributed draws.
"""
function iid_draws(backend::AbstractSBCBackend)
    return false # Default implementation assumes MCMC
end

"""
    default_thin_ranks(backend::AbstractSBCBackend)

Return the default thinning factor for rank calculation.
"""
function default_thin_ranks(backend::AbstractSBCBackend)
    return iid_draws(backend) ? 1 : 10 # Default values from R package
end

"""
    diagnostics(fit_result)

Extract diagnostics from a fit result.
"""
function diagnostics(fit_result)
    error("diagnostics not implemented for fit result type $(typeof(fit_result))")
end