defmodule Flex.Routes do
  defmacro __using__(_opts) do
    quote do
      import Flex.Routes
      @before_compile Flex.Routes
      Module.register_attribute(__MODULE__, :flex_routes, accumulate: true)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __flex_routes__ do
        @flex_routes
      end
    end
  end

  defmacro defroute(name, path, options \\ [], do: block) do
    quote do
      @flex_routes {unquote(name), unquote(path), unquote(options)}
      def unquote(name)(conn, params) do
        var!(conn) = conn
        var!(params) = params
        unquote(block)
      end
    end
  end
end
