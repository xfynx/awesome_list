defmodule AwesomeList.Repo.CategoriesTest do
  use AwesomeList.DataCase

  alias AwesomeList.Repo.{Categories, Languages}

  describe "categories" do
    alias AwesomeList.Repo.Categories.Category

    @valid_attrs %{name: "some name"}
    @invalid_attrs %{name: nil}

    def category_fixture(attrs \\ %{}) do
      {:ok, category} =
        attrs
        |> Enum.into(@valid_attrs |> Map.merge(%{language: Languages.list_languages |> List.first}))
        |> Categories.create_category()

      category
    end

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Categories.list_categories() |> Enum.map(& &1.name) == [category.name]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Categories.get_category!(category.id).name == category.name
    end

    test "create_category/1 with valid data creates a category" do
      attrs = Map.merge(@valid_attrs, %{language: Languages.list_languages |> List.first})
      assert {:ok, %Category{} = category} = Categories.create_category(attrs)
      assert category.name == "some name"
    end

    test "create_category/1 without language returns error" do
      assert {:error, %Ecto.Changeset{}} = Categories.create_category(@valid_attrs)
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Categories.create_category(@invalid_attrs)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Categories.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Categories.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      cat = category_fixture()
      assert %Ecto.Changeset{} = Categories.change_category(cat)
    end

    test ".get_by_name/1" do
      category_fixture(name: "alg")
      ruby = Languages.list_languages |> List.first
      cat = Categories.get_by_name(ruby.id, "alg")
      assert cat.name == "alg"
      assert cat.language != nil

      assert Categories.get_by_name(ruby.id, "kfkfkfkf") == nil
      last_lang = Languages.list_languages |> List.last
      assert Categories.get_by_name(last_lang.id, "alg") == nil
    end
  end
end
