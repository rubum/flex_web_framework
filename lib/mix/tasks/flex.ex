defmodule Mix.Tasks.Flex do
  use Mix.Task

  @shortdoc "Prints Flex tasks and their information"
  def run(_) do
    Mix.shell().info("Flex v#{Application.spec(:flex, :vsn)}")
    Mix.shell().info("Available tasks:")
    Mix.shell().info("  mix flex.new     # Creates a new Flex application")
    Mix.shell().info("  mix flex.server  # Starts a Flex server (development)")
    Mix.shell().info("  mix flex.prod    # Starts a Flex server (production)")
  end
end
