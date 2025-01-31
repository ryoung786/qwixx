import Config

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
# For development, we disable any cache and enable
# debugging and code reloading.
#
config :phoenix, :stacktrace_depth, 20

config :phoenix_live_view,
  # Include HEEx debug annotations as HTML comments in rendered markup
  # The watchers configuration can be used to run external
  # watchers to your application. For example, we can use it
  debug_heex_annotations: true,
  # Enable helpful, but potentially expensive runtime checks
  # to bundle .js and .css sources.
  enable_expensive_runtime_checks: true

config :qwixx, QwixxWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  # ## SSL Support
  #
  # In order to use HTTPS in development, a self-signed
  # certificate can be generated by running the following
  # Mix task:
  #
  #     mix phx.gen.cert
  #
  # Run `mix help phx.gen.cert` for more information.
  #
  # The `http:` config above can be replaced with:
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "RsMn4JMC6SIVvQ3BU/nF37WFt6DU/xlMlBwdPH6lW3DxSBss5kihHLY3b2HLxhrh",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:qwixx, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:qwixx, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
config :qwixx, QwixxWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/qwixx_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
# configured to run both http and https servers on
# different ports.

config :qwixx, dev_routes: true

# Path to install SaladUI components
config :salad_ui, components_path: Path.join(File.cwd!(), "lib/qwixx_web/components")
