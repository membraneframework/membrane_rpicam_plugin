defmodule Membrane.RpicamPlugin.Source do
  @moduledoc """
  Membrane Source Element for capturing live feed from a RasperryPi camera using rpicam-apps based on libcamera
  """

  use Membrane.Source
  alias Membrane.{Buffer, H264, RemoteStream}

  @app_name "libcamera-vid"

  def_output_pad :output,
    accepted_format: %RemoteStream{type: :bytestream, content_format: H264},
    availability: :always,
    flow_control: :push

  def_options timeout: [
                spec: integer() | :infinite,
                default: :infinite,
                description: """
                Time for which program runs in milliseconds.
                """
              ],
              framerate: [
                spec: non_neg_integer() | -1,
                default: -1,
                description: """
                Fixed framerate.
                """
              ],
              width: [
                spec: non_neg_integer(),
                default: 0,
                description: """
                Output image width.
                """
              ],
              height: [
                spec: non_neg_integer(),
                default: 0,
                description: """
                Output image height.
                """
              ]

  @impl true
  def handle_init(_ctx, opts) do
    command = create_command(opts)
    port = Port.open({:spawn, command}, [:binary, :exit_status])

    stream_format = %RemoteStream{type: :bytestream, content_format: H264}

    {[stream_format: {:output, stream_format}], %{app_port: port}}
  end

  @impl true
  def handle_info({port, {:data, data}}, _ctx, %{app_port: port} = state) do
    buffer = %Buffer{payload: data}

    {[buffer: {:output, buffer}], state}
  end

  def handle_info({port, {:exit_status, exit_status}}, _ctx, %{app_port: port} = state) do
    if exit_status == 0 do
      {[end_of_stream: :output], state}
    else
      raise "#{@app_name} error, exit status: #{exit_status}"
    end
  end

  @spec create_command(Membrane.Element.options()) :: String.t()
  defp create_command(opts) do
    timeout =
      case opts.timeout do
        :infinite -> 0
        t when t >= 0 -> t
      end

    "#{@app_name} -t #{timeout} --framerate #{opts.framerate} --width #{opts.width} --height #{opts.height} -o -"
  end
end
