# src/visualization/plots.jl

"""
    plot_rank_hist(results::SBCResults; 
                   variables=nothing, 
                   bins=nothing,
                   prob=0.95)

Plot rank histograms for SBC results.
"""
function plot_rank_hist(results::SBCResults; 
                        variables=nothing, 
                        bins=nothing,
                        prob=0.95)
    
    # Extract and filter statistics
    stats = results.stats
    
    if !isnothing(variables)
        filter_idx = [p in variables for p in stats.parameter]
        stats = stats[filter_idx, :]
    end
    
    # Get unique parameters and check max_rank is consistent
    params = unique(stats.parameter)
    max_ranks = unique(stats.max_rank)
    
    if length(max_ranks) != 1
        @warn "Multiple max_rank values found: $max_ranks. Using the first one."
        max_rank = first(max_ranks)
    else
        max_rank = first(max_ranks)
    end
    
    # Determine number of bins
    if isnothing(bins)
        # Use same logic as R package
        n_sims_per_param = Int(nrow(stats) / length(params))
        bins = min(max_rank + 1, max(floor(Int, n_sims_per_param / 10), 5))
    end
    
    # Create one subplot per parameter
    plots = []
    
    for param in params
        param_stats = filter(r -> r.parameter == param, stats)
        
        # Calculate confidence interval for uniform distribution
        n = length(param_stats.rank)
        expected = n / bins
        
        # Use binomial approximation for CI
        ci_lower = quantile(Binomial(n, 1/bins), 0.5 * (1 - prob))
        ci_upper = quantile(Binomial(n, 1/bins), 0.5 * (1 + prob))
        
        # Create histogram
        p = histogram(param_stats.rank, 
                     bins=bins, 
                     title=string(param),
                     xlabel="Rank",
                     ylabel="Count",
                     legend=false)
        
        # Add reference line and CI
        hline!(p, [expected], color=:gray, linestyle=:dash)
        hline!(p, [ci_lower, ci_upper], color=:lightblue, alpha=0.3)
        
        push!(plots, p)
    end
    
    # Combine plots into a single figure
    if length(plots) == 1
        return first(plots)
    else
        return plot(plots..., layout=(length(plots), 1), size=(800, 300*length(plots)))
    end
end

"""
    plot_ecdf(results::SBCResults; 
              variables=nothing,
              prob=0.95)

Plot empirical CDF plots for SBC results.
"""
function plot_ecdf(results::SBCResults; 
                  variables=nothing,
                  prob=0.95)
    
    # Extract and filter statistics
    stats = results.stats
    
    if !isnothing(variables)
        filter_idx = [p in variables for p in stats.parameter]
        stats = stats[filter_idx, :]
    end
    
    # Get unique parameters and check max_rank is consistent
    params = unique(stats.parameter)
    max_ranks = unique(stats.max_rank)
    
    if length(max_ranks) != 1
        @warn "Multiple max_rank values found: $max_ranks. Using the first one."
        max_rank = first(max_ranks)
    else
        max_rank = first(max_ranks)
    end
    
    # Create one subplot per parameter
    plots = []
    
    for param in params
        param_stats = filter(r -> r.parameter == param, stats)
        
        # Calculate empirical CDF
        sorted_ranks = sort(param_stats.rank)
        n = length(sorted_ranks)
        ecdf_y = (1:n) ./ n
        ecdf_x = sorted_ranks ./ max_rank
        
        # Create plot with fixed domain [0,1]
        x_range = 0:0.01:1
        
        p = plot(x_range, x_range, 
                color=:blue, linestyle=:dash, 
                label="Theoretical", 
                title=string(param),
                xlabel="Rank / Max Rank",
                ylabel="Cumulative Probability")
        
        # Add empirical CDF
        plot!(p, ecdf_x, ecdf_y, color=:black, label="Empirical")
        
        # Add confidence bands (using Kolmogorov-Smirnov limits)
        ks_limit = sqrt(-log(0.5 * (1 - prob)) / (2 * n))
        
        # Calculate CI bounds explicitly to avoid broadcasting issues
        upper_ci = [min(1.0, x + ks_limit) for x in x_range]
        lower_ci = [max(0.0, x - ks_limit) for x in x_range]
        
        plot!(p, x_range, upper_ci, 
             color=:lightblue, alpha=0.3, label="$(prob*100)% CI")
        plot!(p, x_range, lower_ci, 
             color=:lightblue, alpha=0.3, label=nothing)
        
        push!(plots, p)
    end
    
    # Combine plots into a single figure
    if length(plots) == 1
        return first(plots)
    else
        return plot(plots..., layout=(length(plots), 1), size=(800, 300*length(plots)))
    end
end