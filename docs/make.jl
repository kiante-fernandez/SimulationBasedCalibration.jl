using SimulationBasedCalibration
using Documenter

#DocMeta.setdocmeta!(SimulationBasedCalibration, :DocTestSetup, :(using SimulationBasedCalibration); recursive=true)

makedocs(;
    modules=[SimulationBasedCalibration],
    authors="Kiante Fernandez",
    sitename="SimulationBasedCalibration.jl",
    format=Documenter.HTML(;
        canonical="https://kiante-fernandez.github.io/SimulationBasedCalibration.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Examples" => "examples.md",
        "API" => "api.md"
    ],
)

deploydocs(repo = "github.com/kiante-fernandez/SimulationBasedCalibration.jl.git")
