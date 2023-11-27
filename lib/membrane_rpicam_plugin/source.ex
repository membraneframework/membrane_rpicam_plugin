defmodule Membrane.Rpicam.Source do
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
                spec: non_neg_integer() | :infinity,
                default: :infinity,
                description: """
                Time for which program runs in milliseconds.
                """
              ],
              framerate: [
                spec: {pos_integer(), pos_integer()},
                default: {-1, 1},
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
  def handle_playing(_ctx, state) do
    stream_format = %RemoteStream{type: :bytestream, content_format: H264}
    port = Port.open({:spawn, create_command(state)}, [:binary, :exit_status])

    {[stream_format: {:output, stream_format}], %{app_port: port, init_time: nil}}
  end

  @impl true
  def handle_info({port, {:data, data}}, _ctx, %{app_port: port} = state) do
    time = Membrane.Time.monotonic_time()
    init_time = state.init_time || time
    buffer = %Buffer{payload: data, pts: time - init_time}

    {[buffer: {:output, buffer}], %{state | init_time: init_time}}
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
        :infinity -> 0
        t when t >= 0 -> t
      end

    framerate = elem(opts.framerate, 0) / elem(opts.framerate, 1)

    "#{@app_name} -t #{timeout} --framerate #{framerate} --width #{opts.width} --height #{opts.height} -o -"
  end
end
