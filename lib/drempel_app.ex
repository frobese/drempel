defmodule Drempel.App do
  @moduledoc """
  Enables backoff technique to slow down brute force.
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Drempel, [config])
    ]

    opts = [strategy: :one_for_one, name: Drempel.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp config, do: Application.get_env(:drempel, Drempel, [])
end
