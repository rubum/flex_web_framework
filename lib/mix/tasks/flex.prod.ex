defmodule Mix.Tasks.Flex.Prod do
  use Mix.Task

  @shortdoc "Starts a Flex server in production mode"

  @moduledoc """
  Starts a Flex server in production mode.

  ## Command line options
    * `--port` - the port to start the server on (defaults to 4000)
  """

  def run(args) do
    Mix.env(:prod)
    {opts, _, _} = OptionParser.parse(args, switches: [port: :integer])

    Application.put_env(:flex_web, :port, opts[:port] || 4000)

    Mix.Task.run("run", ["--no-halt" | args])
  end
end
