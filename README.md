Drempel
=======

Drempel provides exponential backoffs for Elixir to put speed bumps on your critical actions and slow down brute force attacks.

Default is a truncated binary exponential backoff (2^x - 1), starting out
with 0, 1, 3, ... seconds and cutting off at 4.5 hours.

- exponential backoff x^2, i.e. fn x -> :erlang.bsl(1, x) * 1_000 end
- geometric backoff 2x, i.e. fn x -> 2 * x * 1_000 end
- table based backoff, e.g. fn 0 -> 0; 1 -> 23; 2 -> 42; _ -> 999 end

A bucket cleanup will expunge items older than `stale_timeout`.
In turn one bucket will be cleaned every `cleanup_interval` milliseconds.