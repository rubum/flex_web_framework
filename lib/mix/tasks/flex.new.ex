defmodule Mix.Tasks.Flex.New do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Creates a new Flex project"

  @moduledoc """
  Creates a new Flex project.
  It expects the path of the project as an argument.

      mix flex.new PATH [--module MODULE] [--app APP]

  A project at the given PATH will be created. The
  application name and module name will be retrieved
  from the path, unless `--module` or `--app` is given.
  """

  @switches [app: :string, module: :string]

  def run(args) do
    {opts, argv} = OptionParser.parse!(args, strict: @switches)

    case argv do
      [] ->
        Mix.raise("Expected PATH to be given, please use `mix flex.new PATH`")

      [path | _] ->
        app = opts[:app] || Path.basename(Path.expand(path))
        check_application_name!(app)
        mod = opts[:module] || Macro.camelize(app)
        check_mod_name_validity!(mod)

        unless File.exists?(path) do
          File.mkdir_p!(path)
        end

        File.cd!(path, fn ->
          generate(app, mod, path, opts)
        end)
    end
  end

  # ------- Private -------

  defp generate(app, mod, path, _opts) do
    message = "Hello from Flex!"

    assigns = [
      app: app,
      module: mod,
      app_path: path,
      message: message,
      title: "Welcome to Flex!",
      flex_web_dep: flex_web_dep(),
      main_content: "<p>#{message}</p>"
    ]

    create_file("README.md", readme_template(assigns))
    create_file(".gitignore", gitignore_template(assigns))

    copy_from(paths(), ".", assigns, [
      {:eex, "mix.exs.eex", "mix.exs"},
      {:eex, "README.md.eex", "README.md"},
      {:eex, "config/config.exs.eex", "config/config.exs"},
      {:eex, "config/dev.exs.eex", "config/dev.exs"},
      {:eex, "config/prod.exs.eex", "config/prod.exs"},
      {:eex, "config/test.exs.eex", "config/test.exs"},
      {:eex, "lib/app_name.ex.eex", "lib/#{app}.ex"},
      {:eex, "lib/app_name/application.ex.eex", "lib/#{app}/application.ex"},
      {:eex, "lib/controllers/home_controller.ex.eex", "lib/controllers/home_controller.ex"},
      {:eex, "lib/templates/base/app.html.eex", "lib/templates/base/app.html.eex"},
      {:eex, "lib/templates/home.html.eex", "lib/templates/home.html.eex"},
      {:eex, "lib/templates/about.html.eex", "lib/templates/about.html.eex"}
    ])

    Mix.shell().info("""

    Your Flex project was created successfully.

    Get started:

        cd #{path}
        mix deps.get
        mix flex.server

    Happy flexing!
    """)
  end

  defp flex_web_dep do
    if path = System.get_env("FLEX_PATH") do
      ~s[{:flex, path: #{inspect(path)}, override: true}]
    else
      ~s[{:flex, "~> 0.1.0"}]
    end
  end

  defp check_application_name!(name) do
    unless name =~ ~r/^[a-z][\w_]*$/ do
      Mix.raise(
        "Expected the application name to be a valid Elixir identifier, got: #{inspect(name)}"
      )
    end
  end

  defp check_mod_name_validity!(name) do
    unless name =~ ~r/^[A-Z]\w*(\.[A-Z]\w*)*$/ do
      Mix.raise(
        "Expected the module name to be a valid Elixir alias (Ex: Foo.Bar), got: #{inspect(name)}"
      )
    end
  end

  defp paths do
    archives_path = Mix.path_for(:archives)
    flex_path = find_flex_archive(archives_path)
    [Path.join([flex_path, "priv", "new_app_template"])]
  end

  defp find_flex_archive(archives_path) do
    case File.ls(archives_path) do
      {:ok, files} ->
        Enum.find_value(files, fn file ->
          if String.starts_with?(file, "flex_web") do
            Path.join([archives_path, file, file])
          end
        end)
      {:error, _} ->
        Mix.raise("Could not find Flex archive. Please ensure it's installed.")
    end
  end

  defp copy_from(paths, target_dir, binding, mapping) when is_list(mapping) do
    for {format, source, target} <- mapping do
      source = Path.join(paths, source)
      target = Path.join(target_dir, target)

      case format do
        :eex -> Mix.Generator.copy_template(source, target, binding)
        :text -> Mix.Generator.copy_file(source, target)
      end
    end
  end

  embed_template(:readme, """
  # <%= @module %>

  To start your Flex server:

    * Install dependencies with `mix deps.get`
    * Start Flex endpoint with `mix flex.server`

  Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

  Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/flex_web/deployment.html).

  ## Learn more

    * Official website: https://www.flexweb.dev/
    * Guides: https://hexdocs.pm/flex_web/guides.html
    * Docs: https://hexdocs.pm/flex_web
    * Forum: https://forum.flexweb.dev/
    * Source: https://github.com/rubum/flex
  """)

  embed_template(:gitignore, """
  # The directory Mix will write compiled artifacts to.
  /_build/

  # If you run "mix test --cover", coverage assets end up here.
  /cover/

  # The directory Mix downloads your dependencies sources to.
  /deps/

  # Where 3rd-party dependencies like ExDoc output generated docs.
  /doc/

  # Ignore .fetch files in case you like to edit your project deps locally.
  /.fetch

  # If the VM crashes, it generates a dump, let's ignore it too.
  erl_crash.dump

  # Also ignore archive artifacts (built via "mix archive.build").
  *.ez

  # Ignore package tarball (built via "mix hex.build").
  <%= @app %>-*.tar
  """)
end
