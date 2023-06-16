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

@reexport using StipplePlotly.Charts
@reexport using StipplePlotly.Layouts

@reexport using Genie.Renderer.Html
@reexport using Genie.Server

export @genietools
export Stipple.ReactiveTools.DEFAULT_LAYOUT

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
  return quote
    function __genietools()
      Genie.config.log_to_file = true
      Genie.config.log_requests = false
      Genie.Logger.initialize_logging()

      if haskey(ENV, "BASEPATH") && ! isempty(ENV["BASEPATH"])
        try
          Genie.Assets.assets_config!([Genie, Stipple, StippleUI, StipplePlotly, GenieAutoReload], host = ENV["BASEPATH"])
          Genie.config.websockets_base_path = ENV["BASEPATH"]
          Genie.config.websockets_exposed_port = nothing
        catch ex
          @error ex
        end
      end

      if Genie.Configuration.isprod()
        try
          Genie.Assets.assets_config!([Genie, Stipple, StippleUI, StipplePlotly], host = "https://cdn.statically.io/gh/GenieFramework")
        catch ex
          @error ex
        end
      end

      if Genie.Configuration.isdev()
        GenieDevTools.register_routes()
        GeniePackageManager.register_routes()
        Stipple.deps!(GenieAutoReload, GenieAutoReload.deps)
        @async begin
          autoreload(pwd())
          sleep(2)
          Genie.Watch.watch()
        end
      end

      nothing
    end

    __genietools()
  end |> esc
end

end
