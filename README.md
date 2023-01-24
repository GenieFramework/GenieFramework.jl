# GenieFramework

[![Docs](https://img.shields.io/badge/genieframework-docs-greenyellow)](https://www.genieframework.com/docs/)

Meta package for Genie reactive apps. This packages exports 

`Genie`, `Stipple`, `StippleUI`, `StipplePlotly`, `Stipple.Pages`, `Stipple.ModelStorage.Sessions`, `Stipple.ReactiveTools`, `Genie.Renderer.Html`, `Genie.Server` and other packages from Genie Ecosystem as required in future

## Installation

To install the most recent released version of package:

```
pkg> add GenieFramework
```

## Usage

## Basic application 

Create a simple `app.jl` script
```julia
using GenieFramework
@genietools

d₁ = PlotData(x = [1, 2, 3], y = [4, 1, 2], plot = StipplePlotly.Charts.PLOT_TYPE_BAR, name = "Barcelona")
d₂ = PlotData(x = [1, 2, 3], y = [2, 4, 5], plot = StipplePlotly.Charts.PLOT_TYPE_BAR, name = "London")

@handlers begin
    @out data = [d₁, d₂]
    @out layout = PlotLayout()
end

function ui()
    [
        h1("GenieFramework 🧞 Data Vizualization 📊")
        plot(:data, layout=:layout)
    ]
end

@page("/", ui)

Server.isrunning() || Server.up()
```

```shell
julia> include("app.jl")
```

should start the app at `localhost:8000`
