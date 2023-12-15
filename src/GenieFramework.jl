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

const DEFAULT_LAYOUT = Stipple.ReactiveTools.DEFAULT_LAYOUT
export DEFAULT_LAYOUT
export @genietools

if Genie.Configuration.isdev()
  @reexport using GenieDevTools
  @reexport using GenieAutoReload
  @reexport using GarishPrint
  @reexport using GeniePackageManager
end

# Address conflicts - this is disgusting but necessary
# TODO: Refactor layout exports in next breaking release (v1)
# Both Stipple and StippleUI export layout
const q__layout = StippleUI.Layouts.layout
export q__layout

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

        @async autoreload(pwd()) |> errormonitor

        if ! haskey(ENV, "GENIE_PUSH_ERRORS") || ENV["GENIE_PUSH_ERRORS"] !== "false"
          @async begin
            GenieDevTools.tailapplog(Genie.config.path_log; env = lowercase(ENV["GENIE_ENV"])) do line
              msg = GenieDevTools.parselog(line)
              msg !== nothing || return

              try
                msg = """$(Genie.config.webchannels_eval_command) window.GENIEMODEL.\$q.notify({timeout: 0, message: `$(line)`, color: "red", closeBtn: true})"""
                Stipple.WEB_TRANSPORT[].broadcast(Genie.WebChannels.tagbase64encode(msg))
              catch ex
                @error ex
              end
            end
          end |> errormonitor
        end
      end

      nothing
    end

    if ! isdefined($__module__, :GENIE_TOOLS_LOADED)
      const GENIE_TOOLS_LOADED = true
      @info "Loading GenieTools"

      Genie.Loader.bootstrap(@__MODULE__; show_banner = false)
      Stipple.__init__()
      StippleUI.__init__()
      StipplePlotly.__init__()

      __genietools()
    else
      @warn "GenieTools already loaded, skipping"
    end
  end |> esc
end

end
