defmodule Flex.Controller do
  defmacro __using__(_opts) do
    quote do
      use Flex.Routes
      use Flex.Response
    end
  end
end
