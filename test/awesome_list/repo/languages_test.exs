defmodule AwesomeList.Repo.AwesomeList.LanguagesTest do
  use AwesomeList.DataCase

  alias AwesomeList.Repo.Languages

  describe "languages" do
    alias AwesomeList.Repo.Languages.Language

    @valid_attrs %{list_anchor: "some list_anchor", name: "some name", repo_path: "some repo_path"}
    @update_attrs %{list_anchor: "some updated list_anchor", name: "some updated name", repo_path: "some updated repo_path"}
    @invalid_attrs %{list_anchor: nil, name: nil, repo_path: nil}

    def language_fixture(attrs \\ %{}) do
      {:ok, language} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Languages.create_language()

      language
    end

    test "list_languages/0 returns all languages" do
      assert Languages.list_languages() |> Enum.map(& &1.name) == ["ruby", "elixir", "php"]
    end

    test "get_language!/1 returns the language with given id" do
      language = language_fixture()
      assert Languages.get_language!(language.id) == language
    end

    test "create_language/1 with valid data creates a language" do
      assert {:ok, %Language{} = language} = Languages.create_language(@valid_attrs)
      assert language.list_anchor == "some list_anchor"
      assert language.name == "some name"
      assert language.repo_path == "some repo_path"
    end

    test "create_language/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Languages.create_language(@invalid_attrs)
    end

    test "update_language/2 with valid data updates the language" do
      language = language_fixture()
      assert {:ok, %Language{} = language} = Languages.update_language(language, @update_attrs)
      assert language.list_anchor == "some updated list_anchor"
      assert language.name == "some updated name"
      assert language.repo_path == "some updated repo_path"
    end

    test "update_language/2 with invalid data returns error changeset" do
      language = language_fixture()
      assert {:error, %Ecto.Changeset{}} = Languages.update_language(language, @invalid_attrs)
      assert language == Languages.get_language!(language.id)
    end

    test "delete_language/1 deletes the language" do
      language = language_fixture()
      assert {:ok, %Language{}} = Languages.delete_language(language)
      assert_raise Ecto.NoResultsError, fn -> Languages.get_language!(language.id) end
    end

    test "change_language/1 returns a language changeset" do
      language = language_fixture()
      assert %Ecto.Changeset{} = Languages.change_language(language)
    end

    test "get_by_name/1" do
      ruby = Languages.get_by_name!("ruby")
      assert ruby.list_anchor == "#awesome-ruby"
      assert ruby.repo_path == "markets/awesome-ruby"
    end
  end
end
