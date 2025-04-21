# src/backends/backends.jl

# Include all backend implementations
include("abstract_backend.jl")  # Abstract interface
include("turing_backend.jl")    # Turing.jl backend
# include("stan_backend.jl")    # Stan.jl backend
# include("JAGS_backend.jl")    # JAGS backend

# Export specific backends
export TuringBackend
