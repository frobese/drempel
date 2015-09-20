defmodule Drempel do
  @moduledoc """
  API and GenServer for the backoff handling.
  """

  use GenServer
  alias Drempel.Backoff

  # fallback default opts
  @cleanup_interval 5 * 1000  # milliseconds, i.e. 5 seconds
  @stale_timeout 8 * 60 * 60 * 1000  # milliseconds, i.e. 8 hours
  @backoff_fun &Backoff.exponential_backoff/1

  # Client API

  @doc """
  Starts the Server.
  """
  def start_link(opts \\ []) do
    GenServer.start_link __MODULE__, opts, name: __MODULE__
  end

  @doc """
  Looks up the term `key` from a term `bucket`.

  Returns `{:ok, delay}` if the key exists in the bucket, `:error` otherwise.
  """
  def fetch(bucket, key) do
    GenServer.call __MODULE__, {:fetch, bucket, key}
  end

  @doc """
  Returns the remaining delay associated with `key` in `bucket`.
  If `bucket` doesn't contain `key`, returns `default` (or `0` if not provided).
  """
  def get(bucket, key, default \\ 0) do
    case GenServer.call __MODULE__, {:fetch, bucket, key} do
      {:ok, delay} -> delay
      _ -> default
    end
  end

  @doc """
  Returns the remaining delay associated with `key` in `bucket`.
  If the delay is `0` adds a hit to the term `key` in a given term `bucket`.
  If `bucket` doesn't contain `key`, returns `default` (or `0` if not provided).
  """
  def update(bucket, key, default \\ 0) do
    delay = case GenServer.call __MODULE__, {:fetch, bucket, key} do
      {:ok, delay} -> delay
      _ -> default
    end
    case delay do
      0 ->
        GenServer.cast __MODULE__, {:put, bucket, key}
        0
      other -> other
    end
  end

  @doc """
  Adds a hit to the term `key` in a given term `bucket`.
  """
  def put(bucket, key) do
    GenServer.cast __MODULE__, {:put, bucket, key}
  end

  # Server Callbacks

  def init(opts) do
    state = %{
      cleanup_interval: Keyword.get(opts, :cleanup_interval, @cleanup_interval),
      stale_timeout:    Keyword.get(opts, :stale_timeout, @stale_timeout),
      backoff_fun:      Keyword.get(opts, :backoff_fun, @backoff_fun)}
    Process.send_after(self, :cleanup, state.cleanup_interval)
    :ets.new(__MODULE__, [:named_table])
    {:ok, state}
  end

  def handle_call({:fetch, bucket, key}, _from, state) do
    key = {bucket, key}
    case :ets.lookup(__MODULE__, key) do
      [{_key, hits, access}] ->
        now = :erlang.monotonic_time(:milli_seconds)
        retry_delay = state.backoff_fun.(hits)
        case access + retry_delay - now do
          retry_time when retry_time > 0 ->
            {:reply, {:ok, retry_time}, state}
          _ ->
            {:reply, {:ok, 0}, state}
        end
      [] ->
        {:reply, :error, state}
    end
  end

  def handle_cast({:put, bucket, key}, state) do
    key = {bucket, key}
    now = :erlang.monotonic_time(:milli_seconds)
    :ets.update_counter(__MODULE__, key, {2, 1}, {key, 0, 0})
    :ets.update_element(__MODULE__, key, {3, now})
    {:noreply, state}
  end

  def handle_info(:cleanup, state) do
    stale_time = :erlang.monotonic_time(:milli_seconds) - state.stale_timeout
    match_spec = [{{:_, :_, :"$1"}, [{:<, :"$1", stale_time}], [true]}]
    :ets.select_delete(__MODULE__, match_spec)

    Process.send_after(self, :cleanup, state.cleanup_interval)
    {:noreply, state}
  end
end
