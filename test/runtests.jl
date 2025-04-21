# test/runtests.jl
using SimulationBasedCalibration
using Test
using Random
using Distributions
using DataFrames

@testset "SimulationBasedCalibration.jl" begin
    # Test dataset creation
    @testset "Dataset Generation" begin
        # Create a simple generator function
        function normal_generator(; n_obs=20)
            μ = rand(Normal(0, 1))
            σ = rand(truncated(Normal(0, 1), 0, Inf))
            y = rand(Normal(μ, σ), n_obs)
            
            return Dict(
                :variables => Dict(:μ => μ, :σ => σ),
                :generated => Dict(:y => y)
            )
        end
        
        generator = SBCGeneratorFunction(normal_generator, n_obs=20)
        datasets = generate_datasets(generator, 10)
        
        # Test dimensions
        @test length(datasets) == 10
        @test length(datasets.variables) == 10
        @test length(datasets.generated) == 10
        
        # Test variables
        @test all(haskey.(datasets.variables, :μ))
        @test all(haskey.(datasets.variables, :σ))
        
        # Test generated data
        @test all(haskey.(datasets.generated, :y))
    end
    
    # Test rank calculation
    @testset "Rank Calculation" begin
        # Create simple draws matrix
        draws = DataFrame(
            :a => [1.0, 2.0, 3.0, 4.0, 5.0],
            :b => [0.1, 0.2, 0.3, 0.4, 0.5],
            :c => [5.0, 4.0, 3.0, 2.0, 1.0]
        )
        
        # Test ranks with no ties
        vars1 = Dict(:a => 2.5, :b => 0.35, :c => 3.5)
        ranks1, max_rank1 = SimulationBasedCalibration.calculate_ranks(vars1, draws)
        
        @test ranks1[:a] == 2  # 2 values less than 2.5
        @test ranks1[:b] == 3  # 3 values less than 0.35
        @test ranks1[:c] == 3  # 3 values less than 3.5
        @test max_rank1 == 5
        
        # Test ranks with ties
        draws.d = [1.0, 2.0, 2.0, 2.0, 3.0]
        vars2 = Dict(:d => 2.0)
        
        # Since there are ties with random resolution, we test multiple times
        for _ in 1:10
            ranks2, _ = SimulationBasedCalibration.calculate_ranks(vars2, draws)
            @test 1 <= ranks2[:d] <= 4  # Rank should be between 1 and 4
        end
    end
end