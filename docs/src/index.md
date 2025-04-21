# SimulationBasedCalibration.jl

## Overview

This package provides tools to validate Bayesian models and inference algorithms via simulation-based calibration (SBC). It integrates with:

- [Turing.jl](https://turinglang.org/stable/): Probabilistic programming for Bayesian inference

## Background

Simulation-based calibration (SBC) is a method for validating Bayesian computational methods by checking the self-consistency of the posterior distribution. SBC tests whether your model and inference algorithm can recover known parameter values by repeatedly:

1. Sampling parameters from the prior
2. Simulating data under those parameters
3. Fitting the model to the simulated data
4. Checking if the true parameter values are distributed as expected in the posteriors

For correctly calibrated models and inference algorithms, the rank of the true parameter value within posterior samples should follow a uniform distribution:

## Installation

You can install SimulationBasedCalibration.jl by running:

```julia
using Pkg
Pkg.add("SimulationBasedCalibration")
```

For the development version:

```julia
using Pkg
Pkg.add(url="https://github.com/kiante-fernandez/SimulationBasedCalibration.jl")
```

## Quick Example

This example demonstrates how to use SBC to validate a simple Bayesian model:

```julia
using SimulationBasedCalibration
using Turing, Random, Distributions, Plots

# Set random seed for reproducibility
Random.seed!(2025)

# Define a Turing.jl model (normal mean and standard deviation)
@model function normal_model(data)
    μ ~ Normal(0, 5)
    σ ~ truncated(Normal(0, 3), 0, Inf)
    data ~ MvNormal(fill(μ, length(data)), σ^2 * I)
end

# Define a generator function matching our model
function normal_generator(; n_obs=20)
    # Sample from priors
    μ = rand(Normal(0, 5))
    σ = rand(truncated(Normal(0, 3), 0, Inf))
    
    # Generate data
    data = rand(Normal(μ, σ), n_obs)
    
    return Dict(
        :variables => Dict(:μ => μ, :σ => σ),
        :generated => data
    )
end

# Create generator and backend
generator = SBCGeneratorFunction(normal_generator, n_obs=20)
backend = TuringBackend(normal_model, n_samples=1000, n_chains=2)

# Generate datasets and run SBC
datasets = generate_datasets(generator, 50)
results = compute_sbc(datasets, backend)

# Visualize the results
plot_rank_hist(results)
plot_ecdf(results)
```

The rank histogram should appear uniform if the model is correctly specified and the inference algorithm is working properly.

## References

- Talts, S., Betancourt, M., Simpson, D., Vehtari, A., & Gelman, A. (2018). Validating Bayesian Inference Algorithms with Simulation-Based Calibration. *arXiv Preprint arXiv:1804.06788*.
- Modrák, M., Moon, A. H., Kim, S., Bürkner, P., Huurre, N., Faltejsková, K., ... & Vehtari, A. (2023). Simulation-based calibration checking for Bayesian computation: The choice of test quantities shapes sensitivity. Bayesian Analysis, advance publication, DOI: [10.1214/23-BA1404](https://doi.org/10.1214/23-BA1404).
- Säilynoja, T., Bürkner, P., & Vehtari, A. (2021). Graphical Test for Discrete Uniformity and its Applications in Goodness of Fit Evaluation and Multiple Sample Comparison. *arXiv Preprint arXiv:2103.10522*.
- Gelman, A., Vehtari, A., Simpson, D., Margossian, C. C., Carpenter, B., Yao, Y., ... & Modrák, M. (2020). Bayesian Workflow. *arXiv Preprint arXiv:2011.01808*.
- Schad, D. J., Betancourt, M., & Vasishth, S. (2021). Toward a principled Bayesian workflow in cognitive science. *Psychological Methods, 26(1), 103-126*.