defmodule Flex.Response do
  import Flex.Application, only: [templates_path: 0]

  defmacro __using__(_opts) do
    quote do
      import Flex.Response
    end
  end

  def html_response(conn, template, assigns, opts \\ []) do
    template_content =
      templates_path()
      |> Path.join(template)
      |> Flex.TemplateCache.get_template()
      |> EEx.eval_string(assigns: assigns)

    base_template = opts[:base] || "base/app.html.eex"

    base_assigns =
      Map.merge(assigns, %{
        main_content: template_content,
        title: opts[:title] || "Flex App"
      })

    evaluated =
      templates_path()
      |> Path.join(base_template)
      |> EEx.eval_file(assigns: base_assigns)
      |> inject_live_reload_script()

    Plug.Conn.send_resp(conn, 200, evaluated)
  end

  def json_response(conn, data) do
    json = Jason.encode!(data)

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(200, json)
  end

  # ---- Private -----

  defp inject_live_reload_script(html) do
    script = """
    <script>
      (function() {
        var ws = new WebSocket('ws://' + window.location.host + '/ws/live_reload');
        ws.onmessage = function(msg) {
          if (msg.data === 'reload') {
            console.log('Reloading page...');
            window.location.reload();
          }
        };
        ws.onclose = function() {
          console.log('WebSocket closed. Attempting to reconnect...');
          setTimeout(function() {
            window.location.reload();
          }, 20000);
        };
        setInterval(function() {
          if (ws.readyState === WebSocket.OPEN) {
            ws.send('ping');
          }
        }, 300000);
      })();
    </script>
    """

    String.replace(html, "</body>", script <> "</body>")
  end
end
