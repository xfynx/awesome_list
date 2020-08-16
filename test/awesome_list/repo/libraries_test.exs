defmodule AwesomeList.Repo.LibrariesTest do
  use AwesomeList.DataCase

  alias AwesomeList.Repo.{Libraries, Categories, Languages}

  describe "libraries" do
    alias AwesomeList.Repo.Libraries.Library

    @valid_attrs %{description: "some description", last_commit_at: ~N[2010-04-17 14:00:00], name: "some name", stars_count: 42, url: "some url"}
    @update_attrs %{description: "some updated description", last_commit_at: ~N[2011-05-18 15:01:01], name: "some updated name", stars_count: 43, url: "some updated url"}
    @invalid_attrs %{description: nil, last_commit_at: nil, name: nil, stars_count: nil, url: nil}

    def category_fixture(attrs \\ %{}) do
      case Categories.list_categories() |> List.first do
        nil ->
          {:ok, category} =
            attrs
            |> Enum.into(%{name: "some name"}
            |> Map.merge(%{language: Languages.list_languages |> List.first}))
            |> Categories.create_category()

          category

        category ->
          category
      end
    end

    def library_fixture(attrs \\ %{}) do
      {:ok, library} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Libraries.create_library()

      library
    end

    test "list_libraries/0 returns all libraries" do
      library = library_fixture(%{category: category_fixture()})
      assert Libraries.list_libraries() |> Enum.map(& &1.name) == [library.name]
    end

    test "get_library!/1 returns the library with given id" do
      library = library_fixture(%{category: category_fixture()})
      assert Libraries.get_library!(library.id).name == library.name
    end

    test "create_library/1 with valid data creates a library" do
      assert {:ok, %Library{} = library} = Libraries.create_library(Map.merge(@valid_attrs, %{category: category_fixture()}))
      assert library.description == "some description"
      assert library.last_commit_at == ~N[2010-04-17 14:00:00]
      assert library.name == "some name"
      assert library.stars_count == 42
      assert library.url == "some url"
    end

    test "create_library/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Libraries.create_library(@invalid_attrs)
    end

    test "update_library/2 with valid data updates the library" do
      library = library_fixture(%{category: category_fixture()})
      assert {:ok, %Library{} = library} = Libraries.update_library(library, Map.merge(@update_attrs, %{category: category_fixture()}))
      assert library.description == "some updated description"
      assert library.last_commit_at == ~N[2011-05-18 15:01:01]
      assert library.name == "some updated name"
      assert library.stars_count == 43
      assert library.url == "some updated url"
    end

    test "update_library/2 with invalid data returns error changeset" do
      library = library_fixture(%{category: category_fixture()})
      assert {:error, %Ecto.Changeset{}} = Libraries.update_library(library, @invalid_attrs)
      assert library.name == Libraries.get_library!(library.id).name
    end

    test "delete_library/1 deletes the library" do
      library = library_fixture(%{category: category_fixture()})
      assert {:ok, %Library{}} = Libraries.delete_library(library)
      assert_raise Ecto.NoResultsError, fn -> Libraries.get_library!(library.id) end
    end

    test "change_library/1 returns a library changeset" do
      library = library_fixture(%{category: category_fixture()})
      assert %Ecto.Changeset{} = Libraries.change_library(library)
    end

    test ".insert_or_update!/2" do
      lib = Libraries.insert_or_update!(category_fixture(), %{name: "lib2", url: "aaaa"})
      assert lib.url == "aaaa"
      assert lib.id == Libraries.insert_or_update!(category_fixture(), %{name: "lib2", url: "bbb"}).id
      assert Repo.reload(lib).url == "bbb"

      Repo.delete(lib)
    end
  end
end
