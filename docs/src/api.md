# API

## Module

```@docs
SimulationBasedCalibration
```

## Core Types

```@autodocs
Modules = [SimulationBasedCalibration]
Order   = [:type]
```

## Core Functions

The following are organized by category to avoid duplicates:

### Generator Functions

```@autodocs
Modules = [SimulationBasedCalibration]
Order   = [:function]
Filter  = t -> (occursin("generator", lowercase(string(t))) || occursin("generate_datasets", string(t))) && 
              !(occursin("backend", lowercase(string(t))) || 
                occursin("compute", lowercase(string(t))) || 
                occursin("calculate", lowercase(string(t))) || 
                occursin("thin", lowercase(string(t))) || 
                occursin("plot", lowercase(string(t))) || 
                occursin("fit", lowercase(string(t))) || 
                occursin("draw", lowercase(string(t))) || 
                occursin("diagnostic", lowercase(string(t))))
```

### Backend Functions

```@autodocs
Modules = [SimulationBasedCalibration]
Order   = [:function]
Filter  = t -> (occursin("backend", lowercase(string(t))) || 
                occursin("fit", lowercase(string(t))) || 
                occursin("draw", lowercase(string(t))) || 
                occursin("diagnostics", lowercase(string(t))) || 
                occursin("iid_draws", lowercase(string(t)))) && 
              !(occursin("compute", lowercase(string(t))) || 
                occursin("calculate", lowercase(string(t))) || 
                occursin("thin", lowercase(string(t))) || 
                occursin("plot", lowercase(string(t))))
```

### Computation Functions

```@autodocs
Modules = [SimulationBasedCalibration]
Order   = [:function]
Filter  = t -> (occursin("compute", lowercase(string(t))) || 
                occursin("calculate", lowercase(string(t))) || 
                occursin("thin", lowercase(string(t)))) && 
              !(occursin("plot", lowercase(string(t))))
```

### Visualization Functions

```@autodocs
Modules = [SimulationBasedCalibration]
Order   = [:function]
Filter  = t -> occursin("plot", lowercase(string(t)))
```

### Other Functions

```@autodocs
Modules = [SimulationBasedCalibration]
Order   = [:function]
Filter  = t -> !(occursin("generator", lowercase(string(t))) || 
                 occursin("generate_datasets", string(t)) || 
                 occursin("backend", lowercase(string(t))) || 
                 occursin("fit", lowercase(string(t))) || 
                 occursin("draw", lowercase(string(t))) || 
                 occursin("diagnostics", lowercase(string(t))) || 
                 occursin("iid_draws", lowercase(string(t))) || 
                 occursin("compute", lowercase(string(t))) || 
                 occursin("calculate", lowercase(string(t))) || 
                 occursin("thin", lowercase(string(t))) || 
                 occursin("plot", lowercase(string(t))))
```