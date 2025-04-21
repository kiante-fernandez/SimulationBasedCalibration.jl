# Examples

## Basic Usage

Here's a basic example of using SimulationBasedCalibration.jl with Turing.jl:

```julia
using SimulationBasedCalibration
using Turing, Random, Distributions

# Set random seed for reproducibility
Random.seed!(123)

# Define the correct model
@model function normal_model(data)
    # Priors
    μ ~ Normal(0, 5)
    σ ~ truncated(Normal(0, 3), 0, Inf)
    
    # Likelihood - correctly parameterized
    data ~ MvNormal(fill(μ, length(data)), σ^2 * I)
end

# Define a generator function matching our model
function normal_generator(; n_obs=20)
    μ = rand(Normal(0, 5))
    σ = rand(truncated(Normal(0, 3), 0, Inf))
    data = rand(Normal(μ, σ), n_obs)
    
    return Dict(
        :variables => Dict(:μ => μ, :σ => σ),
        :generated => data
    )
end

# Create generator and backend
generator = SBCGeneratorFunction(normal_generator, n_obs=200)
backend = TuringBackend(normal_model, n_samples=1000, n_chains=3)

# Generate datasets
datasets = generate_datasets(generator, 100)

# Run SBC
results = compute_sbc(datasets, backend)

# Visualize the results
p1 = plot_rank_hist(results)
p2 = plot_ecdf(results)
```

## Detecting Model Misspecification

You can also use SBC to detect misspecified models:

```julia
# Define an incorrect model
@model function normal_model_bad(data)
    # Priors 
    μ ~ Normal(0, 5)
    σ ~ truncated(Normal(0, 3), 0, Inf)
    
    # Likelihood - incorrectly parameterized (using precision instead of sd)
    data ~ MvNormal(fill(μ, length(data)), (1/σ)^2 * I)
end

# Create a backend for the bad model
backend_bad = TuringBackend(normal_model_bad, n_samples=1000, n_chains=2)

# Run SBC with the bad model
results_bad = compute_sbc(datasets, backend_bad)

# Compare results
plot_rank_hist(results_bad)
```
