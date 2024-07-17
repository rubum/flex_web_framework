# Flex

<p align="center">
  <svg width="100" height="100" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
    <rect x="40" y="40" width="80" height="80" fill="#3B82F6" transform="rotate(15 80 80)"/>
    <rect x="80" y="80" width="80" height="80" fill="#60A5FA" transform="rotate(-15 120 120)"/>
  </svg>
</p>

<p align="center">
  <strong>A lightweight, flexible web framework for Elixir</strong>
</p>

<p align="center">
  <a href="https://hex.pm/packages/flex">
    <img src="https://img.shields.io/hexpm/v/flex.svg" alt="Hex version"/>
  </a>
  <a href="https://hexdocs.pm/flex">
    <img src="https://img.shields.io/badge/hex-docs-brightgreen.svg" alt="Hex Docs"/>
  </a>
  <!-- <a href="https://github.com/your-repo/flex/actions">
    <img src="https://github.com/your-repo/flex/workflows/CI/badge.svg" alt="CI Status"/>
  </a> -->
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"/>
  </a>
</p>

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [License](#license)

## Introduction

Flex is a lightweight and flexible web framework for Elixir, designed to make web development a breeze. Inspired by the simplicity of Sinatra and powered by the robustness of Elixir, Flex provides developers with an intuitive API for building scalable web applications quickly and efficiently.

## Features

- **Intuitive Routing**: Define your routes with a clean, expressive syntax
- **Blazing Fast**: Leverages the power of the BEAM VM for high performance
- **Hot Code Reloading**: Enjoy seamless development with automatic code reloading
- **Flexible Structure**: Organize your code the way that makes sense for your project
- **Templating**: Built-in support for EEx templates with layouts
- **Static File Serving**: Easily serve static assets
- **Plug Integration**: Seamless integration with the Plug ecosystem
- **Extensible**: Easy to extend with custom modules and plugins

## Installation

Add Flex to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:flex_web, "~> 0.1.0"},
    {:file_system, "~> 0.2"},
    {:jason, "~> 1.2"},
  ]
end
```

Then run `mix deps.get` to install the dependency.

## Quick Start

Create a new Flex project:

```elixir
mix flex.new my_app
cd my_app
mix deps.get
```

Start your Flex server:
```elixir
mix flex.server
```

Visit `http://localhost:4000` in your browser to see your Flex application in action!

## Usage
### Defining Routes

```elixir
defmodule MyApp.Controllers.HomeController do
  use Flex.Controller

  defroute :index, "/" do
    html_response(conn, "home.html.eex", %{message: "Welcome to Flex!"})
  end

  defroute :about, "/about" do
    html_response(conn, "about.html.eex", %{})
  end

  defroute :api_example, "/api/example", methods: [:get] do
    json_response(conn, %{message: "This is a JSON response"})
  end
end
```

### Templates
Flex uses EEx for templating. Templates are located in the `lib/templates` directory.

Example template (`lib/templates/home.html.eex`):

```elixir
<h1>Welcome to Flex</h1>
<p><%= @message %></p>
```

### Static Files

Place your static files in the `priv/static` directory. They will be automatically served.

### Configuration

Configure Flex in your `config/config.exs`:

```elixir
config :flex_web,
  port: 4000,
  static_path: Path.join(File.cwd!, "priv/static"),
  templates_path: Path.join(File.cwd!, "lib/templates")
```

## Contributing

We welcome contributions to Flex! Please see our CONTRIBUTING.md for details on how to get started.
  1. Fork the repository
  2. Create your feature branch (`git checkout -b feature/amazing-feature`)
  3. Commit your changes (`git commit -am 'Add some amazing feature'`)
  4. Push to the branch (`git push origin feature/amazing-feature`)
  5. Open a Pull Request

## License

Distributed under the MIT License. See [LICENSE](https://github.com/rubum/flex/blob/main/LICENSE) for more information.

##

<p align="center">Made with ❤️ by the Flex Team</p>


