if Code.ensure_loaded?(Phoenix.Controller) do
  defmodule Drempel.Plugs.RateLimit do
    @moduledoc """
    Use this plug to enforce a rate limit on a Phoenix action,
    the default key is conn.remote_ip,
    the default bucket is {controller_module, action_name}.
    """

    alias Plug.Conn
    @behaviour Plug

    import Phoenix.Controller, only: [action_name: 1, controller_module: 1]

    @doc false
    def init(opts) do
      opts = Enum.into(opts, %{})
      %{handler: {Map.get(opts, :handler, __MODULE__), :rate_exceeded},
        key: Map.get(opts, :key, nil),
        bucket: Map.get(opts, :bucket, nil)}
    end

    @doc false
    def call(%Conn{} = conn, opts) do
      key = Map.get(opts, :key) || conn.remote_ip
      bucket = Map.get(opts, :bucket) || {controller_module(conn), action_name(conn)}

      case Drempel.get(bucket, key) do
        0 -> conn
        delay -> handle_limit(conn, div(delay, 1000), opts)
      end
    end

    @doc """
    Adds to the limit and assigns to :backoff if a backoff is needed
    """
    def update(%Conn{} = conn, opts) do
      opts = Enum.into(opts, %{})
      key = Map.get(opts, :key) || conn.remote_ip
      bucket = Map.get(opts, :bucket) || {controller_module(conn), action_name(conn)}

      case Drempel.update(bucket, key) do
        0 -> conn
        delay ->
          conn
          |> Conn.assign(:backoff, delay)
      end
    end

    @doc """
    A default rate limit exceeded handler that just sends 429 "Too Many Requests".
    """
    def rate_exceeded(conn, _params) do
      conn
      |> Conn.send_resp(429, "Too Many Requests")
    end

    defp handle_limit(conn, delay, opts) do
      conn = conn
        |> Conn.assign(:backoff, delay)
        |> Conn.halt

      {mod, meth} = Map.get(opts, :handler)
      apply(mod, meth, [conn, conn.params])
    end
  end
end