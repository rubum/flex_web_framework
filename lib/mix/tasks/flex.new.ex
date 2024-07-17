defmodule Mix.Tasks.Flex.New do
  use Mix.Task
  import Mix.Generator

  @template_path Path.expand("../../../priv/new_app_template", __DIR__)

  @impl Mix.Task
  def run([name | _]) do
    app = String.downcase(name)
    module = Macro.camelize(app)

    assigns = [app: app, module: module, title: "Welcome to Flex!", message: "Hello from Flex!"]

    create_directory(app)
    copy_from(@template_path, app, assigns)

    Mix.shell().info("""

    Your Flex application #{app} has been created successfully.

    To get started, run the following commands:

        $ cd #{app}
        $ mix deps.get
        $ mix flex.server

    Enjoy your Flex journey!
    """)
  end

  defp copy_from(template_path, target_app, assigns) do
    files = [
      {:eex, "mix.exs.eex", "mix.exs"},
      {:eex, "README.md.eex", "README.md"},
      {:eex, "config/config.exs.eex", "config/config.exs"},
      {:eex, "config/dev.exs.eex", "config/dev.exs"},
      {:eex, "config/prod.exs.eex", "config/prod.exs"},
      {:eex, "config/test.exs.eex", "config/test.exs"},
      {:eex, "lib/app_name.ex.eex", "lib/#{assigns[:app]}.ex"},
      {:eex, "lib/app_name/application.ex.eex", "lib/#{assigns[:app]}/application.ex"},
      {:eex, "lib/controllers/home_controller.ex.eex", "lib/controllers/home_controller.ex"},
      {:eex, "lib/templates/base/app.html.eex", "lib/templates/base/app.html.eex"},
      {:eex, "lib/templates/home.html.eex", "lib/templates/home.html.eex"},
      {:eex, "lib/templates/about.html.eex", "lib/templates/about.html.eex"},
    ]

    for {format, source, target} <- files do
      source = Path.join(template_path, source)
      target = Path.join(target_app, target)

      case format do
        :eex ->
          contents = EEx.eval_file(source, assigns: assigns)
          create_file(target, contents)
        :text ->
          File.cp!(source, target)
      end
    end
  end
end
