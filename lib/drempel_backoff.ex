defmodule Drempel.Backoff do
  @moduledoc """
  Backoff functions for Drempel
  """

  @doc """
  Backoff function based on exponential growth.
  """
  def exponential_backoff(x) when x > 14,
    do: exponential_backoff(14)
  def exponential_backoff(x),
    do: (:erlang.bsl(1, x) - 1) * 1_000

  @doc """
  Backoff function based on geometric growth.
  """
  def geometric_backoff(x),
    do: 2 * x * 1_000

  @doc """
  Example tabled backoff function.
  """
  def table_backoff(0),  do:           0 * 1_000
  def table_backoff(1),  do:           1 * 1_000
  def table_backoff(2),  do:           2 * 1_000
  def table_backoff(3),  do:           5 * 1_000
  def table_backoff(4),  do:          10 * 1_000
  def table_backoff(5),  do:          15 * 1_000
  def table_backoff(6),  do:          30 * 1_000
  def table_backoff(7),  do:     1  * 60 * 1_000
  def table_backoff(8),  do:     2  * 60 * 1_000
  def table_backoff(9),  do:     5  * 60 * 1_000
  def table_backoff(10), do:     10 * 60 * 1_000
  def table_backoff(11), do:     15 * 60 * 1_000
  def table_backoff(12), do:     30 * 60 * 1_000
  def table_backoff(13), do: 1 * 60 * 60 * 1_000
  def table_backoff(14), do: 2 * 60 * 60 * 1_000
  def table_backoff(_),  do: 4 * 60 * 60 * 1_000
end
