import Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :qwixx, QwixxWeb.Endpoint,
  url: [host: "qwixx.ryoung.info", port: 4001],
  cache_static_manifest: "priv/static/cache_manifest.json",
  check_origin: ["https://qwixx.ryoung.info"],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Logger config

config :logflare_logger_backend,
  # https://api.logflare.app is configured by default and you can set your own url
  url: "https://api.logflare.app",
  # Default LogflareLogger level is :info. Note that log messages are filtered by the :logger application first
  level: :info,
  api_key: System.get_env("LOGFLARE_API_KEY"),
  source_id: System.get_env("LOGFLARE_SOURCE_ID"),
  # minimum time in ms before a log batch is sent to the server ",
  flush_interval: 1_000,
  # maximum number of events before a log batch is sent to the server
  max_batch_size: 50

config :logger,
  # or other Logger level,
  level: :info,
  backends: [:console, LogflareLogger.HttpBackend]

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :qwixx, QwixxWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [
#         port: 443,
#         cipher_suite: :strong,
#         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#         certfile: System.get_env("SOME_APP_SSL_CERT_PATH"),
#         transport_options: [socket_opts: [:inet6]]
#       ]
#
# The `cipher_suite` is set to `:strong` to support only the
# latest and more secure SSL ciphers. This means old browsers
# and clients may not be supported. You can set it to
# `:compatible` for wider support.
#
# `:keyfile` and `:certfile` expect an absolute path to the key
# and cert in disk or a relative path inside priv, for example
# "priv/ssl/server.key". For all supported SSL configuration
# options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
#
# We also recommend setting `force_ssl` in your endpoint, ensuring
# no data is ever sent via http, always redirecting to https:
#
#     config :qwixx, QwixxWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.
