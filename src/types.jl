# src/types.jl

"""
    AbstractSBCBackend

Abstract type for SBC backends (model fitting implementations)
"""
abstract type AbstractSBCBackend end

"""
    AbstractSBCGenerator

Abstract type for SBC generators (data generation mechanisms)
"""
abstract type AbstractSBCGenerator end

"""
    SBCDatasets

Structure to hold generated datasets and corresponding parameter values.

# Fields
- `variables`: Array of dictionaries with true parameter values
- `generated`: Array of generated datasets
"""
struct SBCDatasets
    variables::Vector{Dict{Symbol, Any}}
    generated::Vector{Any}
end

"""
    SBCResults

Structure to hold SBC results.

# Fields
- `stats`: DataFrame with SBC statistics
- `fits`: Vector of fit objects
- `errors`: Vector of error objects
"""
struct SBCResults
    stats::DataFrame
    fits::Vector{Any}
    errors::Vector{Any}
end

# Define basic operations for our types
Base.length(d::SBCDatasets) = length(d.variables)
Base.getindex(d::SBCDatasets, i) = SBCDatasets(d.variables[i], d.generated[i])

Base.length(r::SBCResults) = length(r.fits)

function Base.getindex(r::SBCResults, indices)
    # Filter stats by sim_id
    if nrow(r.stats) > 0
        subset_stats = filter(row -> row.sim_id ∈ indices, r.stats)
        
        # Remap the sim_id values
        if nrow(subset_stats) > 0
            unique_ids = sort(unique(subset_stats.sim_id))
            id_map = Dict(old_id => new_id for (new_id, old_id) in enumerate(unique_ids))
            subset_stats.sim_id = [id_map[id] for id in subset_stats.sim_id]
        end
    else
        subset_stats = r.stats  # Empty DataFrame
    end
    
    return SBCResults(
        subset_stats,
        r.fits[indices],
        r.errors[indices]
    )
end