module GenieFramework

using Revise
using Reexport

@reexport using Genie
@reexport using Stipple
@reexport using StippleUI
@reexport using StipplePlotly

@reexport using Stipple.Pages
@reexport using Stipple.ModelStorage.Sessions
@reexport using Stipple.ReactiveTools

@reexport using Genie.Renderer.Html
@reexport using Genie.Server

export @genietools

if Genie.Configuration.isdev()
  @reexport using GenieDevTools
  @reexport using GenieAutoReload
  @reexport using GarishPrint
  @reexport using GeniePackageManager
end

macro genietools()
  if Genie.Configuration.isprod()
    return quote
      Genie.Assets.assets_config!([Genie, Stipple, StippleUI, StipplePlotly], host = "https://cdn.statically.io/gh/GenieFramework")
    end |> esc
  end

  quote
    if Genie.Configuration.isdev()
      Genie.Logger.initialize_logging()
      GenieDevTools.register_routes()
      GeniePackageManager.register_routes()
      GeniePackageManager.deps_routes()
      Stipple.deps!(GenieAutoReload, GenieAutoReload.deps)
      @async begin
        autoreload(pwd())
        sleep(2)
        Genie.Watch.watch()
      end
    end

    nothing
  end |> esc
end

end
