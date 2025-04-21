# SimulationBasedCalibration

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://kiante-fernandez.github.io/SimulationBasedCalibration.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://kiante-fernandez.github.io/SimulationBasedCalibration.jl/dev/)
[![Build Status](https://github.com/kiante-fernandez/SimulationBasedCalibration.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/kiante-fernandez/SimulationBasedCalibration.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Build Status](https://app.travis-ci.com/kiante-fernandez/SimulationBasedCalibration.jl.svg?branch=main)](https://app.travis-ci.com/kiante-fernandez/SimulationBasedCalibration.jl)
[![Coverage](https://codecov.io/gh/kiante-fernandez/SimulationBasedCalibration.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/kiante-fernandez/SimulationBasedCalibration.jl)

SimulationBasedCalibration.jl provides tools to validate your Bayesian model and/or sampling algorithm via the self-recovering property of Bayesian models. This package lets you run SBC easily and perform postprocessing and visualizations of the results to assess computational faithfulness.

## Installation

To install the development version of SimulationBasedCalibration.jl, run:

```julia
using Pkg
Pkg.add(url="https://github.com/kiante-fernandez/SimulationBasedCalibration.jl")
```

## Quick Tour

To use SBC, you need:
1. A function that generates simulated data that should match your model (a _generator_)
2. A statistical model + algorithm + algorithm parameters that can fit the model to data (a _backend_)

SBC then lets you asssess when the backend and generator don't encode the same data generating process.

For a quick example, we'll use a simple generator producing normally distributed data with a Turing.jl model that either correctly or incorrectly matches the generator:

```julia
using SimulationBasedCalibration
using Turing, Random, Distributions

# Define the correct model
@model function normal_model(data)
    # Priors
    μ ~ Normal(0, 5)
    σ ~ truncated(Normal(0, 3), 0, Inf)
    
    # Likelihood - correctly parameterized
    data ~ MvNormal(fill(μ, length(data)), σ^2 * I)
end

# Define an incorrect model
@model function normal_model_bad(data)
    # Priors 
    μ ~ Normal(0, 5)
    σ ~ truncated(Normal(0, 3), 0, Inf)
    
    # Likelihood - incorrectly parameterized (using precision instead of sd)
    data ~ MvNormal(fill(μ, length(data)), (1/σ)^2 * I)
end

# Define a generator function matching our correct model
function normal_generator(; n_obs=20)
    μ = rand(Normal(0, 5))
    σ = rand(truncated(Normal(0, 3), 0, Inf))
    data = rand(Normal(μ, σ), n_obs)
    
    return Dict(
        :variables => Dict(:μ => μ, :σ => σ),
        :generated => data
    )
end

# Create generator and backends
generator = SBCGeneratorFunction(normal_generator, n_obs=20)
backend_correct = TuringBackend(normal_model, n_samples=1000, n_chains=2)
backend_bad = TuringBackend(normal_model_bad, n_samples=1000, n_chains=2)

# Generate datasets
datasets = generate_datasets(generator, 50)

# Run SBC with both backends
results_correct = compute_sbc(datasets, backend_correct)
results_bad = compute_sbc(datasets, backend_bad)

# Visualize the results
plot_rank_hist(results_correct)
plot_rank_hist(results_bad)

plot_ecdf(results_correct)
plot_ecdf(results_bad)
```

The diagnostics plots will show uniformly distributed ranks for the correct model, while the bad model will show non-uniform ranks, indicating a mismatch between the generative process and the model.

## Backends

Currently, SimulationBasedCalibration.jl supports Turing.jl models as backends. Support for other methods is planned for future releases.

## Parallelization

For computationally intensive models, you can use Julia's built-in parallelization capabilities:

```julia
using Distributed
addprocs(4)  # Adds 4 worker processes

@everywhere using SimulationBasedCalibration, Turing
# Define model and generator on all workers...

# Now run SBC
results = compute_sbc(datasets, backend)
```

## More Information

For more detailed information, see the [documentation](https://kiante-fernandez.github.io/SimulationBasedCalibration.jl/stable/).

## Citing SBC and Related Software

When using SBC, please cite the following publication:

Fernandez, K. (2025). SimulationBasedCalibration.jl: A Julia package for simulation-based calibration of Bayesian models. *arXiv Preprint*.

## References

* Talts, S., Betancourt, M., Simpson, D., Vehtari, A., & Gelman, A. (2018). Validating Bayesian Inference Algorithms with Simulation-Based Calibration. *arXiv Preprint arXiv:1804.06788*.
* Modrák, M., Moon, A. H., Kim, S., Bürkner, P., Huurre, N., Faltejsková, K., ... & Vehtari, A. (2023). Simulation-based calibration checking for Bayesian computation: The choice of test quantities shapes sensitivity. Bayesian Analysis, advance publication, DOI: [10.1214/23-BA1404](https://doi.org/10.1214/23-BA1404).
* Säilynoja, T., Bürkner, P., & Vehtari, A. (2021). Graphical Test for Discrete Uniformity and its Applications in Goodness of Fit Evaluation and Multiple Sample Comparison. *arXiv Preprint arXiv:2103.10522*.
* Gelman, A., Vehtari, A., Simpson, D., Margossian, C. C., Carpenter, B., Yao, Y., ... & Modrák, M. (2020). Bayesian Workflow. *arXiv Preprint arXiv:2011.01808*.
* Schad, D. J., Betancourt, M., & Vasishth, S. (2021). Toward a principled Bayesian workflow in cognitive science. *Psychological Methods, 26(1), 103-126*.

## Acknowledgements

This package is a Julia implementation of the R package [SBC](https://github.com/hyunjimoon/SBC). We thank the original authors for their contributions.