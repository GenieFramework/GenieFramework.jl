using Documenter

push!(LOAD_PATH,  "../../src")

using GenieFramework

makedocs(
    sitename = "GenieFramework - Meta Package for Genie Ecosystem",
    format = Documenter.HTML(prettyurls = false),
    pages = [
        "Home" => "index.md",
        "GenieFramework API" => [
          "GenieFramework" => "API/genieframework.md",
        ]
    ],
)

deploydocs(
  repo = "github.com/GenieFramework/GenieFramework.jl.git",
)
