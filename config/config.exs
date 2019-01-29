use Mix.Config

config :drempel, Drempel,
  # milliseconds, i.e. 5 seconds
  cleanup_interval: 5_000,
  # milliseconds, i.e. 8 hours
  stale_timeout: 8 * 60 * 60 * 1000,
  backoff_fun: &Drempel.Backoff.exponential_backoff/1
