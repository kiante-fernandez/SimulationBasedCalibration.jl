# src/generators.jl

"""
    SBCGeneratorFunction <: AbstractSBCGenerator

A generator that uses a function to create datasets.

# Fields
- `func`: Function that generates a single dataset
- `kwargs`: Keyword arguments to pass to the function
"""
struct SBCGeneratorFunction <: AbstractSBCGenerator
    func::Function
    kwargs::Dict{Symbol, Any}
end

"""
    SBCGeneratorFunction(func; kwargs...)

Create a generator from a function with keyword arguments.
"""
function SBCGeneratorFunction(func; kwargs...)
    return SBCGeneratorFunction(func, Dict{Symbol, Any}(kwargs))
end

"""
    generate_datasets(generator::SBCGeneratorFunction, n_sims::Int)

Generate n_sims datasets using the given generator.
"""
function generate_datasets(generator::SBCGeneratorFunction, n_sims::Int)
    variables = Vector{Dict{Symbol, Any}}(undef, n_sims)
    generated = Vector{Any}(undef, n_sims)
    
    for i in 1:n_sims
        result = generator.func(; generator.kwargs...)
        
        if !haskey(result, :variables) || !haskey(result, :generated)
            error("Generator function must return a Dict with :variables and :generated keys")
        end
        
        variables[i] = result[:variables]
        generated[i] = result[:generated]
    end
    
    return SBCDatasets(variables, generated)
end