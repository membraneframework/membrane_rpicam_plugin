defmodule Membrane.RpicamPluginTest do
  use ExUnit.Case

  import Membrane.ChildrenSpec

  @tag :manual
  test "manual test" do
    spec =
      child(:source, %Membrane.Rpicam.Source{timeout: 5000})
      |> child(:sink, %Membrane.File.Sink{location: "/data/output.h264"})

    pipeline = Membrane.Testing.Pipeline.start_link_supervised!(spec: spec)

    Process.sleep(1_000)
    assert Process.alive?(pipeline)
    Process.sleep(4_500)

    Membrane.Pipeline.terminate(pipeline)
  end
end
