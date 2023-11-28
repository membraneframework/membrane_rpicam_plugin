defmodule Membrane.Rpicam.Source do
  @moduledoc """
  Membrane Source Element for capturing live feed from a RasperryPi camera using rpicam-apps based on libcamera
  """

  use Membrane.Source
  alias Membrane.{Buffer, H264, RemoteStream}

  @app_name "libcamera-vid"

  def_output_pad :output,
    accepted_format: %RemoteStream{type: :bytestream, content_format: H264},
    flow_control: :push

  def_options timeout: [
                spec: Membrane.Time.non_neg() | :infinity,
                default: :infinity,
                description: """
                Time for which program runs in milliseconds.
                """
              ],
              framerate: [
                spec: {pos_integer(), pos_integer()} | :camera_default,
                default: :camera_default,
                description: """
                Fixed framerate.
                """
              ],
              width: [
                spec: pos_integer() | :camera_default,
                default: :camera_default,
                description: """
                Output image width.
                """
              ],
              height: [
                spec: pos_integer() | :camera_default,
                default: :camera_default,
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

  @impl true
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

    {framerate_num, framerate_denom} = resolve_defaultable_option(opts.framerate, {-1, 1})
    framerate_float = framerate_num / framerate_denom

    width = resolve_defaultable_option(opts.width, 0)
    height = resolve_defaultable_option(opts.height, 0)

    "#{@app_name} -t #{timeout} --framerate #{framerate_float} --width #{width} --height #{height} -o -"
  end

  defp resolve_defaultable_option(option, default) do
    case option do
      :camera_default -> default
      x -> x
    end
  end
end
