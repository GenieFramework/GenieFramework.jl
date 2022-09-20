module GenieFramework

using Reexport

@reexport using Genie
@reexport using Stipple
@reexport using StippleUI
@reexport using StipplePlotly

@reexport using Stipple.Pages
@reexport using Stipple.ModelStorage.Sessions
@reexport using Stipple.ReactiveTools

export @devtools

macro devtools()
  Genie.Configuration.isdev() || return :(nothing)

  quote
    using GenieDevTools
    using GenieAutoReload

    Genie.Logger.initialize_logging()

    GenieDevTools.register_routes()
    Stipple.deps!(GenieAutoReload, GenieAutoReload.deps)
    autoreload(pwd())

    @async begin
      sleep(2)
      Genie.Watch.watch()
    end
  end |> esc
end

end
