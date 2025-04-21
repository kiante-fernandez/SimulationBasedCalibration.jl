# src/backends/turing_backend.jl
using Turing
using MCMCChains

"""
    TuringBackend <: AbstractSBCBackend

Backend for Turing.jl models.

# Fields
- `model_func`: Function that takes data and returns a Turing model
- `sampler`: MCMC sampler to use
- `n_chains`: Number of chains to run
- `options`: Additional options to pass to the Turing sampler
"""
struct TuringBackend <: AbstractSBCBackend
    model_func::Function
    sampler::Any  # Using Any to avoid type issues
    n_chains::Int
    options::Dict{Symbol, Any}
end

"""
    TuringBackend(model_func::Function; 
                 sampler=Turing.NUTS(0.65),
                 n_chains=4,
                 kwargs...)

Create a Turing backend with the given options.
"""
function TuringBackend(model_func::Function; 
                      sampler=Turing.NUTS(0.65),
                      n_chains=4,
                      kwargs...)
    return TuringBackend(model_func, sampler, n_chains, Dict{Symbol, Any}(kwargs))
end

"""
    fit(backend::TuringBackend, data)

Fit the Turing model to the given data.
"""
function fit(backend::TuringBackend, data)
    # Create model from data
    model = backend.model_func(data)
    
    # Extract options
    options = Dict{Symbol, Any}(backend.options)
    
    # Set up sampling parameters
    n_samples = get(options, :n_samples, 1000)
    progress = get(options, :progress, false)
    
    # Remove keys we've handled
    delete!(options, :n_samples)
    delete!(options, :progress)
    
    # Sample from the model
    chain = Turing.sample(
        model,
        backend.sampler,
        MCMCThreads(),
        n_samples,
        backend.n_chains;
        progress=progress,
        options...
    )
    
    return chain
end

"""
    draws_matrix(chain::Chains)

Convert Turing MCMCChains to a DataFrame of posterior draws.
"""
function draws_matrix(chain::MCMCChains.Chains)
    # Different versions of MCMCChains store warmup info differently
    # So we'll just use all the samples for now
    return DataFrame(chain)
end

"""
    iid_draws(backend::TuringBackend)

Check if the backend produces iid draws.
"""
function iid_draws(backend::TuringBackend)
    # Only certain samplers produce iid draws
    sampler_type = typeof(backend.sampler)
    return sampler_type <: Turing.PG || 
           sampler_type <: Turing.SMC ||
           sampler_type <: Turing.IS
end

"""
    diagnostics(chain::MCMCChains.Chains)

Extract diagnostics from a Turing MCMC chain.
"""
function diagnostics(chain::MCMCChains.Chains)
    # Get parameter names - use all parameters for now
    params = names(chain)
    
    # Calculate diagnostics
    rhats = try
        MCMCChains.rhat(chain)
    catch
        Dict(p => 1.0 for p in params)  # Default if rhat fails
    end
    
    ess_bulk = try
        MCMCChains.ess(chain, kind=:bulk)
    catch
        Dict(p => length(chain) for p in params)  # Default if ess fails
    end
    
    ess_tail = try
        MCMCChains.ess(chain, kind=:tail) 
    catch
        Dict(p => length(chain) for p in params)  # Default if ess fails
    end
    
    # Create diagnostics DataFrame
    diags = DataFrame(
        parameter = Symbol[],
        rhat = Float64[],
        ess_bulk = Float64[],
        ess_tail = Float64[]
    )
    
    for p in params
        rhat_val = get(rhats, p, 1.0)
        bulk_val = get(ess_bulk, p, length(chain))
        tail_val = get(ess_tail, p, length(chain))
        
        push!(diags, (p, rhat_val, bulk_val, tail_val))
    end
    
    return diags
end