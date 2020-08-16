defmodule AwesomeList.Github.ClientTest do
  use AwesomeList.DataCase
  import Tesla.Mock
  alias AwesomeList.Github.Client

  @url "https://api.github.com/some_request"
  @body_rate_limited %{message: "API rate limit exceeded"}
  @body_ok %{ok: true}

  defp mock_request(:last_remaining, reset) do
    mock(fn _ ->
      %Tesla.Env{
        headers: headers(0, reset),
        status: 200,
        body: @body_ok
      }
    end)
  end

  defp mock_request(:check_limit, reset) do
    mock(fn _ ->
      now = System.system_time(:second)

      case now < reset do
        true ->
          %Tesla.Env{
            headers: headers(0, reset),
            status: 304,
            body: @body_rate_limited
          }

        false ->
          %Tesla.Env{
            headers: headers(60, now + 60),
            status: 200,
            body: @body_ok
          }
      end
    end)
  end

  defp headers(remaining, reset_time) do
    [
      {"x-ratelimit-limit", "60"},
      {"x-ratelimit-remaining", remaining |> to_string()},
      {"x-ratelimit-reset", reset_time |> to_string()}
    ]
  end

  defp measure_request_time() do
    time_start = System.system_time(:millisecond)
    {:ok, env} = Client.get(@url)
    assert %{ok: true} == env.body

    System.system_time(:millisecond) - time_start
  end

  describe "requesting github api" do
    test "respects rate limits" do
      reset = System.system_time(:second) + 2
      mock_request(:last_remaining, reset)
      assert measure_request_time() < 30
      mock_request(:check_limit, reset)
      assert measure_request_time() > 1900
    end
  end

  test ".repo_meta/1" do
    mock(fn %{method: :get, url: "https://api.github.com/repos/xxx/yyy"} ->
      %Tesla.Env{
        status: 200,
        body: json_fixture("repo_example")
      }
    end)
    assert Client.repo_meta("https://github.com/xxx/yyy") == {:ok, %{
             description: "Dalmatiner flow processing library.",
             last_commit_at: ~N[2017-09-26 22:44:20],
             stars_count: 11
           }}
  end

  test ".readme/1" do
    mock(fn %{method: :get, url: "https://github.com/user/some_repo/blob/master/README.md"} ->
      %Tesla.Env{
        status: 200,
        body: File.read!("test/fixtures/awesome-elixir.html")
      }
    end)
    assert {:ok, _some_string} = Client.readme("user/some_repo")
  end
end
