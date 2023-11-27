# Membrane Rpicam Plugin

Membrane Rpicam Plugin allows capturing video from RaspberryPi camera using [rpicam-apps](https://github.com/raspberry-pi/rpicam-apps).

## Installation

The package can be installed by adding `membrane_rpicam_plugin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:membrane_rpicam_plugin, "~> 0.1.0"}
  ]
end
```

## Usage

The following pipeline captures 5 seconds from the RaspberryPi camera and saves it to `/data/output.h264`:

```elixir
defmodule Rpicam.Pipeline do
  use Membrane.Pipeline
  
  @impl true
  def handle_init(_ctx, _opts) do
    spec =   
      child(:source, %Membrane.Rpicam.Source{timeout: 5000})
      |> child(:sink, %Membrane.File.Sink{location: "/data/output.h264"})

    {[spec: spec], %{}}
  end
end
```

## Copyright and License

Copyright 2022, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_rpicam_plugin)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_rpicam_plugin)

Licensed under the [Apache License, Version 2.0](LICENSE)