# Membrane Rpicam Plugin

[![Hex.pm](https://img.shields.io/hexpm/v/membrane_rpicam_plugin.svg)](https://hex.pm/packages/membrane_rpicam_plugin)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](https://hexdocs.pm/membrane_rpicam_plugin)
[![CircleCI](https://circleci.com/gh/membraneframework/membrane_rpicam_plugin.svg?style=svg)](https://circleci.com/gh/membraneframework/membrane_rpicam_plugin)

Membrane Rpicam Plugin allows capturing video from official RaspberryPi camera module using [rpicam-apps](https://github.com/raspberry-pi/rpicam-apps) (formerly libcamera-apps). This plugin can also be used on devices running [Nerves](https://nerves-project.org).

## Installation

The package can be installed by adding `membrane_rpicam_plugin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:membrane_rpicam_plugin, "~> 0.1.3"}
  ]
end
```

The package depends on rpicam-apps that need to be present on the target system.

## Usage

The following script creates and starts a pipeline capturing 5 seconds from the RaspberryPi camera module and saving it to `/data/output.h264`:

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

  @impl true
  def handle_element_end_of_stream(:sink, _pad, _ctx, state) do
    {[terminate: :normal], state}
  end

  @impl true
  def handle_element_end_of_stream(_child, _pad, _ctx, state) do
    {[], state}
  end
end

# Start and monitor the pipeline
{:ok, _supervisor_pid, pipeline_pid} = Membrane.Pipeline.start_link(Rpicam.Pipeline)
ref = Process.monitor(pipeline_pid)

# Wait for the pipeline to finish
receive do
  {:DOWN, ^ref, :process, _pipeline_pid, _reason} ->
    :ok
end
```

## Copyright and License

Copyright 2022, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_rpicam_plugin)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_rpicam_plugin)

Licensed under the [Apache License, Version 2.0](LICENSE)