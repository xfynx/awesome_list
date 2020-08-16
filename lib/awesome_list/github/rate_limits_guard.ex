defmodule AwesomeList.Github.RateLimitsGuard do
  use Agent
  require Logger

  @behaviour Tesla.Middleware

  @header_remaining "x-ratelimit-remaining"
  @header_reset "x-ratelimit-reset"

  def start_link(_) do
    Agent.start_link(fn -> {60, 0} end, name: __MODULE__)
  end

  def call(env, next, _options) do
    delay_till_rate_limits_reset()

    case Tesla.run(env, next) do
      {:ok, env} ->
        update_rate_limits(env)
        {:ok, env}

      other ->
        other
    end
  end

  defp delay_till_rate_limits_reset() do
    {remaining, reset} = Agent.get(__MODULE__, & &1)

    case remaining do
      0 ->
        wait_until(reset)

      _ ->
        :ok
    end
  end

  defp wait_until(time) do
    delay =
      (time - :os.system_time(:second) + 1)
      |> max(0)
      |> Kernel.*(1000)

    Logger.info("Waiting for rate limits resetting (#{delay} ms)")
    Process.sleep(delay)
  end

  defp update_rate_limits(env) do
    remaining = get_header_int(env, @header_remaining, 60)
    reset = get_header_int(env, @header_reset, 0)

    Agent.update(__MODULE__, fn _ -> {remaining, reset} end)
  end

  defp get_header_int(env, header, default) do
    case Tesla.get_header(env, header) do
      nil -> default
      value -> String.to_integer(value)
    end
  end
end