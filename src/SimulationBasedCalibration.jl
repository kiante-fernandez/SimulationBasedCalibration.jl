module SimulationBasedCalibration

using Random
using Distributions
using StatsBase
using DataFrames
using Plots

# Core abstract types
export AbstractSBCBackend, AbstractSBCGenerator
export SBCDatasets, SBCResults

# Functions for generating datasets
export generate_datasets, SBCGeneratorFunction

# Functions for computing SBC
export compute_sbc, calculate_ranks

# Visualization functions
export plot_rank_hist, plot_ecdf

# Include subdirectories
include("types.jl")                  # Core types
include("generators.jl")             # Dataset generators
include("backends/backends.jl")      # Backend interface
include("compute.jl")                # SBC computation
include("visualization/plots.jl")    # Visualization

end # module