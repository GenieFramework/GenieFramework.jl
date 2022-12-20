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

"""
This macro configures static assets(js, icons, fonts etc) based on production or development mode. 
  
In production mode, it uses the CDN to load the assets.
In development mode, it loads the assets from the local file system.

It also register routes from GenieDevTools and GeniePackageManager per app basis which means making available routes from 
GenieDevTools and GeniePackageManager in your Genie/GenieBuilder app for development purposes. 

Some example routes are:
- `/geniepackagemanager`
- `/_devtools_/save`
- `/_devtools_/up`
- `/_devtools_/down`
- `/_devtools_/log`
- `/_devtools_/startrepl` etc.

which can be accessed from `app_host:app_port/geniepackagemanager` etc.
"""
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
