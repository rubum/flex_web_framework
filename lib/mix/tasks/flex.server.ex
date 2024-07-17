defmodule Mix.Tasks.Flex.Server do
  use Mix.Task

  @shortdoc "Starts a Flex server"

  @moduledoc """
  Starts a Flex server.

  ## Command line options
    * `--port` - the port to start the server on (defaults to 4000)
  """

  @spec run([binary()]) :: any()
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, strict: [port: :integer])
    port = opts[:port] || 4100

    Application.put_env(:flex_web, :port, port)

    Mix.Task.run("run", run_args() ++ ["--no-halt"])
  end

  defp run_args do
    if iex_running?(), do: [], else: ["--no-halt"]
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) && IEx.started?
  end
end
