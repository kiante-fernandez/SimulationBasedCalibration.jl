# src/compute.jl

"""
    compute_sbc(datasets::SBCDatasets, 
                backend::AbstractSBCBackend;
                keep_fits::Bool=true,
                thin_ranks::Int=default_thin_ranks(backend),
                ensure_num_ranks_divisor::Int=2)

Compute SBC results for the given datasets using the specified backend.
"""
function compute_sbc(datasets::SBCDatasets, 
                     backend::AbstractSBCBackend;
                     keep_fits::Bool=true,
                     thin_ranks::Int=default_thin_ranks(backend),
                     ensure_num_ranks_divisor::Int=2)
    
    n_sims = length(datasets)
    fits = Vector{Any}(undef, n_sims)
    errors = Vector{Any}(undef, n_sims)
    stats_list = Vector{DataFrame}()
    
    for i in 1:n_sims
        try
            # Fit model to data
            fit_result = fit(backend, datasets.generated[i])
            
            # Store fit if requested
            fits[i] = keep_fits ? fit_result : nothing
            
            # Compute statistics
            stats_i = compute_statistics(
                fit_result,
                datasets.variables[i],
                thin_ranks,
                ensure_num_ranks_divisor
            )
            
            # Add simulation ID
            stats_i.sim_id .= i
            
            push!(stats_list, stats_i)
            errors[i] = nothing
        catch e
            # Store error and continue
            errors[i] = e
            fits[i] = nothing
            @warn "Error in simulation $i: $(e)"
        end
    end
    
    # Combine all statistics
    stats = length(stats_list) > 0 ? vcat(stats_list...) : DataFrame()
    
    return SBCResults(stats, fits, errors)
end

"""
    compute_statistics(fit_result, variables, thin_ranks, ensure_num_ranks_divisor)

Compute SBC statistics for a single fit.
"""
function compute_statistics(fit_result, variables, thin_ranks, ensure_num_ranks_divisor)
    # Convert fit to draws matrix
    draws = draws_matrix(fit_result)
    
    # Apply thinning
    thinned_draws = thin_draws(draws, thin_ranks)
    
    # Ensure number of ranks is divisible by ensure_num_ranks_divisor
    n_draws = size(thinned_draws, 1)
    n_discard = (n_draws + 1) % ensure_num_ranks_divisor
    
    if n_discard > 0
        n_keep = n_draws - n_discard
        if n_keep > 0
            thinned_draws = thinned_draws[1:n_keep, :]
        end
    end
    
    # Calculate ranks
    ranks, max_rank = calculate_ranks(variables, thinned_draws)
    
    # Calculate summary statistics
    params = collect(keys(variables))
    n_params = length(params)
    
    # Build DataFrame with results
    stats = DataFrame(
        parameter = Symbol[],
        simulated_value = Float64[],
        mean = Float64[],
        median = Float64[],
        std = Float64[],
        q5 = Float64[],
        q95 = Float64[],
        rank = Int[],
        max_rank = Int[],
        z_score = Float64[]
    )
    
    for param in params
        # Skip if parameter not in posterior draws
        if !hasproperty(draws, param)
            continue
        end
        
        param_draws = draws[:, param]
        
        # Calculate statistics
        param_mean = mean(param_draws)
        param_std = std(param_draws)
        param_median = median(param_draws)
        param_q5 = quantile(param_draws, 0.05)
        param_q95 = quantile(param_draws, 0.95)
        
        # Get true value and rank
        true_value = variables[param]
        param_rank = ranks[param]
        
        # Calculate z-score
        z_score = (true_value - param_mean) / param_std
        
        push!(stats, (
            param,
            true_value,
            param_mean,
            param_median,
            param_std,
            param_q5,
            param_q95,
            param_rank,
            max_rank,
            z_score
        ))
    end
    
    return stats
end

"""
    thin_draws(draws, thin)

Apply thinning to posterior draws.
"""
function thin_draws(draws, thin)
    if thin <= 1
        return draws
    else
        return draws[1:thin:end, :]
    end
end

"""
    calculate_ranks(variables, draws)

Calculate the rank of each true parameter value within posterior draws.
"""
function calculate_ranks(variables, draws)
    max_rank = size(draws, 1)
    ranks = Dict{Symbol, Int}()
    
    for (param, true_value) in pairs(variables)
        # Skip parameters not in the posterior
        if !hasproperty(draws, param)
            continue
        end
        
        param_draws = draws[:, param]
        
        # Count draws less than true value
        less_than = sum(param_draws .< true_value)
        
        # Count draws equal to true value (for discrete parameters)
        equal_to = sum(param_draws .== true_value)
        
        if equal_to > 0
            # Stochastic rank assignment for ties
            ranks[param] = less_than + rand(0:equal_to)
        else
            ranks[param] = less_than
        end
    end
    
    return ranks, max_rank
end