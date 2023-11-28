# Membrane Rpicam Plugin

Membrane Rpicam Plugin allows capturing video from official RaspberryPi camera module using [rpicam-apps](https://github.com/raspberry-pi/rpicam-apps) (formerly libcamera-apps). This plugin can also be used on devices running [Nerves](https://nerves-project.org).

## Installation

The package can be installed by adding `membrane_rpicam_plugin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:membrane_rpicam_plugin, "~> 0.1.0"}
  ]
end
```

The package depends on rpicam-apps that need to be present on the target system.

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

## Testing

To run manual tests and verify them you need to have access to testing environment on your target device (not possible on Nerves).

First, install dependendencies:

```shell
mix deps.get
```

Then run tests with manual tag: 

```shell
mix test --include manual
```

After 5 seconds `output.h264` file should be created in current working directory containing footage from the camera. You can play it with software like FFmpeg.

## Copyright and License

Copyright 2022, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_rpicam_plugin)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_rpicam_plugin)

Licensed under the [Apache License, Version 2.0](LICENSE)