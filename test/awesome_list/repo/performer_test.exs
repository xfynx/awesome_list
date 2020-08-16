defmodule AwesomeList.Repo.PerformerTest do
  use AwesomeList.DataCase
  import Tesla.Mock

  alias AwesomeList.Repo.{Performer, Languages, Categories, Libraries}

  def get_result_by_language(language) do
    language
    |> Repo.preload([:categories, categories: [:libraries]])
    |> Jason.encode!
    |> Jason.decode!
  end

  test ".call/1" do
    mock_global(
      fn
        %{method: :get, url: "https://github.com/h4cc/awesome-elixir/blob/master/README.md"} ->
          %Tesla.Env{
            status: 200, body: File.read!("test/fixtures/small_list_example.html")
          }
        %{method: :get, url: "https://api.github.com/repos/thoughtbot/bamboo"} ->
          %Tesla.Env{
            status: 200, body: %{"pushed_at" => "2015-01-23T23:50:07", "description" => "aaa", "stargazers_count" => 444}
          }
        %{method: :get, url: "https://api.github.com/repos/exthereum/ex_rlp"} ->
          %Tesla.Env{
            status: 200, body: %{"pushed_at" => "2019-01-23T23:50:07", "description" => "bbb", "stargazers_count" => 1110}
          }
        %{method: :get, url: "https://api.github.com/repos/SenecaSystems/huffman"} ->
          %Tesla.Env{
            status: 200, body: %{"pushed_at" => "2017-01-23T23:50:07", "description" => "sdf", "stargazers_count" => 777}
          }
      end
    )
    Performer.call("elixir")

    assert %{
      "categories" => [
        %{
          "libraries" => [
            %{
              "description" => "aaa",
              "last_commit_at" => "2015-01-23T23:50:07",
              "name" => "bamboo",
              "stars_count" => 444,
              "url" => "https://github.com/thoughtbot/bamboo"
            }
          ],
          "name" => "Email"
        },
        %{"libraries" => [], "name" => "Embedded Systems"},
        %{
          "libraries" => [
            %{
              "description" => "bbb",
              "last_commit_at" => "2019-01-23T23:50:07",
              "name" => "ex_rlp",
              "stars_count" => 1110,
              "url" => "https://github.com/exthereum/ex_rlp"
            },
            %{
              "description" => "sdf",
              "last_commit_at" => "2017-01-23T23:50:07",
              "name" => "huffman",
              "stars_count" => 777,
              "url" => "https://github.com/SenecaSystems/huffman"
            }
          ],
          "name" => "Encoding and Compression"
        }
      ],
      "list_anchor" => "#awesome-elixir",
      "name" => "elixir",
      "repo_path" => "h4cc/awesome-elixir"
    } = get_result_by_language(Languages.get_by_name!("elixir"))

    Repo.delete_all(Libraries.Library)
    Repo.delete_all(Categories.Category)
  end

  test ".save/2 должен создавать или обновлять в базе категории и библиотеки" do
    elixir = Languages.get_by_name!("elixir")
    data_to_save = %{
      "Actors" => [
        %{
          name: "dflow",
          url: "https://github.com/dalmatinerdb/dflow",
          description: "nomatter",
          stars_count: 10,
          last_commit_at: ~N[2015-01-23 23:50:07]
        },
        %{
          name: "aaa",
          url: "urlurl",
          stars_count: 100
        }
      ],
      "SomeCategory" => [
        %{
          name: "lib1",
          description: "nomatter"
        }
      ],
      "EmptyCategory" => []
    }

    # убеждаемся, что категории с библиотеками для другого языка, даже если названия совпадают, не аффектит
    ruby = Languages.get_by_name!("ruby")
    Performer.save("ruby", %{"SomeCategory" => [%{name: "lib1", description: "nomatter"}]})
    ruby_result = %{
      "categories" => [
        %{
          "libraries" => [
            %{
              "description" => "nomatter",
              "last_commit_at" => nil,
              "name" => "lib1",
              "stars_count" => nil,
              "url" => nil
            }
          ],
          "name" => "SomeCategory"
        }
      ],
      "list_anchor" => "#awesome-ruby",
      "name" => "ruby",
      "repo_path" => "markets/awesome-ruby"
    }
    assert ruby_result = get_result_by_language(ruby)

    assert Categories.get_by_name(elixir.id, "Actors") == nil
    assert Categories.get_by_name(elixir.id, "SomeCategory") == nil
    assert Categories.get_by_name(elixir.id, "EmptyCategory") == nil

    Performer.save("elixir", data_to_save)

    assert %{
             "categories" => [
               %{
                 "libraries" => [
                   %{
                     "description" => "nomatter",
                     "last_commit_at" => "2015-01-23T23:50:07",
                     "name" => "dflow",
                     "stars_count" => 10,
                     "url" => "https://github.com/dalmatinerdb/dflow"
                   },
                   %{
                     "description" => nil,
                     "last_commit_at" => nil,
                     "name" => "aaa",
                     "stars_count" => 100,
                     "url" => "urlurl"
                   }
                 ],
                 "name" => "Actors"
               },
               %{"libraries" => [], "name" => "EmptyCategory"},
               %{
                 "libraries" => [
                   %{
                     "description" => "nomatter",
                     "last_commit_at" => nil,
                     "name" => "lib1",
                     "stars_count" => 0,
                     "url" => nil
                   }
                 ],
                 "name" => "SomeCategory"
               }
             ],
             "list_anchor" => "#awesome-elixir",
             "name" => "elixir",
             "repo_path" => "h4cc/awesome-elixir"
           } = get_result_by_language(elixir)

    data_to_update = %{
      "Actors" => [
        %{
          name: "aaa",
          url: "url2",
          stars_count: 100
        },
      ],
      "SomeCategory" => [],
      "EmptyCategory" => []
    }

    Performer.save("elixir", data_to_update)
    assert %{
             "categories" => [
               %{
                 "libraries" => [
                   %{
                     "description" => nil,
                     "last_commit_at" => nil,
                     "name" => "aaa",
                     "stars_count" => 100,
                     "url" => "url2"
                   }
                 ],
                 "name" => "Actors"
               },
               %{"libraries" => [], "name" => "EmptyCategory"},
               %{"libraries" => [], "name" => "SomeCategory"}
             ],
             "list_anchor" => "#awesome-elixir",
             "name" => "elixir",
             "repo_path" => "h4cc/awesome-elixir"
           } = get_result_by_language(elixir)

    # убеждаемся, что изменения применены только для списка эликсира
    assert ruby_result = get_result_by_language(ruby)

    Repo.delete_all(Libraries.Library)
    Repo.delete_all(Categories.Category)
  end

  test ".enrich/1" do
    mock_global(
      fn
        %{method: :get, url: "https://api.github.com/repos/infinitered/elasticsearch-elixir"} ->
        %Tesla.Env{
          status: 200, body: %{"pushed_at" => "2015-01-23T23:50:07", "description" => "descr1", "stargazers_count" => 11}
        }
        %{method: :get, url: "https://api.github.com/repos/Tyler-pierce/giza_sphinxsearch"} ->
          %Tesla.Env{
            status: 200, body: %{"pushed_at" => "2019-01-23T23:50:07", "description" => "descr2", "stargazers_count" => 0}
          }
        %{method: :get, url: "https://api.github.com/repos/talklittle/ffmpex"} ->
          %Tesla.Env{
            status: 200, body: %{"pushed_at" => "2017-01-23T23:50:07", "description" => "descr3", "stargazers_count" => 100}
          }
      end
    )

    data = %{
      "Search" => [
        {"elasticsearch", "https://github.com/infinitered/elasticsearch-elixir"},
        {"giza_sphinxsearch", "https://github.com/Tyler-pierce/giza_sphinxsearch"}
      ],
      "Video" => [
        {"ffmpex", "https://github.com/talklittle/ffmpex"},
      ],
      "Empty" => []
    }

    assert Performer.enrich(data) == %{
             "Search" => [
               %{
                 description: "descr1",
                 last_commit_at: ~N[2015-01-23 23:50:07],
                 name: "elasticsearch",
                 stars_count: 11,
                 url: "https://github.com/infinitered/elasticsearch-elixir"
               },
               %{
                 description: "descr2",
                 last_commit_at: ~N[2019-01-23 23:50:07],
                 name: "giza_sphinxsearch",
                 stars_count: 0,
                 url: "https://github.com/Tyler-pierce/giza_sphinxsearch"
               }
             ],
             "Video" => [
               %{
                 description: "descr3",
                 last_commit_at: ~N[2017-01-23 23:50:07],
                 name: "ffmpex",
                 stars_count: 100,
                 url: "https://github.com/talklittle/ffmpex"
               }
             ],
             "Empty" => []
           }
  end
end