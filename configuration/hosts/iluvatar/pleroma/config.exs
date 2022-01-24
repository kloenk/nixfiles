import Config

config :pleroma, Pleroma.Web.Endpoint,
  url: [host: System.get_env("DOMAIN", "localhost"), scheme: "https", port: 443],
  #http: [port: 0, ip: {:local, "/run/pleroma/pleroma.socket"}],
  http: [port: 0, transport_options: %{socket_opts: [fd: 3]}],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :pleroma, :instance,
  name: "SocialKloenk",
  email: "social@kloenk.dev",
  notify_email: "social@kloenk.dev",
  limit: 5000,
  registrations_open: false,
  healthcheck: true

config :pleroma, Pleroma.Captcha,
  enabled: false

config :pleroma, Pleroma.Repo,
  adapter:    Ecto.Adapters.Postgres,
  socket_dir: "/run/postgresql",
  database: "pleroma",
  pool_size: 10

config :pleroma, :database, rum_enabled: false
config :pleroma, :instance, static_dir: "/var/lib/pleroma/static"
config :pleroma, Pleroma.Uploaders.Local, uploads: "/var/lib/pleroma/uploads"

config :pleroma, :mrf,
  policies: [Pleroma.Web.ActivityPub.MRF.SimplePolicy]

config :pleroma, :mrf_simple,
  reject: [
    "freespeechextremist.com",
    "gleasonator.com",
    "gab.com",
    "gab.ai",
    "spinster.xyz",
    "shitposter.club",
    "neckbeard.xyz",
    "gitmo.life"
  ]

config :pleroma, :restrict_unauthenticated,
  timelines: %{local: false, federated: true}

config :pleroma, configurable_from_database: false
