defmodule AwesomeList.Github.ReadmeParserTest do
  use AwesomeList.DataCase
  alias AwesomeList.Github.ReadmeParser

  describe ".parse_readme/2" do
    test "должен распарсить awesome-list ruby" do
      data = File.read!("test/fixtures/awesome-ruby.html")
      {:ok, result} = ReadmeParser.parse_readme(data, "#awesome-ruby")
      assert Enum.count(result) == 103
      assert result["Admin Interface"] == [
               {"ActiveScaffold", "https://github.com/activescaffold/active_scaffold"},
               {"Administrate", "https://github.com/thoughtbot/administrate"},
               {"RailsAdmin", "https://github.com/sferik/rails_admin"},
               {"Trestle", "https://github.com/TrestleAdmin/trestle"}
             ]

      assert result["Automation"] == [
               {"ActiveWorkflow", "https://github.com/automaticmode/active_workflow"},
               {"Danger", "https://github.com/danger/danger"},
               {"Huginn", "https://github.com/cantino/huginn"}
             ]

      assert result["Pagination"] == [
               {"Kaminari", "https://github.com/amatsuda/kaminari"},
               {"order_query", "https://github.com/glebm/order_query"},
               {"Pagy", "https://github.com/ddnexus/pagy"},
               {"will_paginate", "https://github.com/mislav/will_paginate"}
             ]
    end

    test "должен распарсить awesome-list elixir" do
      data = File.read!("test/fixtures/awesome-elixir.html")
      {:ok, result} = ReadmeParser.parse_readme(data, "#awesome-elixir")
      assert Enum.count(result) == 81
      # проверим выборочно некоторые категории
      assert %{
               "Actors" => [
                 {"dflow", "https://github.com/dalmatinerdb/dflow"},
                 {"exactor", "https://github.com/sasa1977/exactor"},
                 {"exos", "https://github.com/awetzel/exos"},
                 {"flowex", "https://github.com/antonmi/flowex"},
                 {"mon_handler", "https://github.com/tattdcodemonkey/mon_handler"},
                 {"pool_ring", "https://github.com/camshaft/pool_ring"},
                 {"poolboy", "https://github.com/devinus/poolboy"},
                 {"pooler", "https://github.com/seth/pooler"},
                 {"sbroker", "https://github.com/fishcakez/sbroker"},
                 {"workex", "https://github.com/sasa1977/workex"},
               ],
               "Benchmarking" => [
                 {"benchee", "https://github.com/PragTob/benchee"},
                 {"benchfella", "https://github.com/alco/benchfella"},
                 {"bmark", "https://github.com/joekain/bmark"}
               ],
               "SMS" => [],

               "Search" => [
                 {"elasticsearch", "https://github.com/infinitered/elasticsearch-elixir"},
                 {"giza_sphinxsearch", "https://github.com/Tyler-pierce/giza_sphinxsearch"}
               ],
               "Video" => [
                 {"ffmpex", "https://github.com/talklittle/ffmpex"},
                 {"silent_video", "https://github.com/talklittle/silent_video"}
               ]
             } = result

      assert result["Version Control"] == [{"gitex", "https://github.com/awetzel/gitex"}]
      assert result["Translations and Internationalizations"] == [
               {"exkanji", "https://github.com/ikeikeikeike/exkanji"},
               {"exromaji", "https://github.com/ikeikeikeike/exromaji"},
               {"getatrex", "https://github.com/alexfilatov/getatrex"},
               {"gettext", "https://github.com/elixir-lang/gettext"},
               {"linguist", "https://github.com/chrismccord/linguist"},
               {"parabaikElixirConverter", "https://github.com/Arkar-Aung/ParabaikElixirConverter"},
               {"trans", "https://github.com/belaustegui/trans"}
             ]
    end

    test "должен распарсить awesome-list php" do
      data = File.read!("test/fixtures/awesome-php.html")
      {:ok, result} = ReadmeParser.parse_readme(data, "#awesome-php")
      assert Enum.count(result) == 64
      assert result["API"] == [
               {"Laminas API Tool Skeleton", "https://github.com/laminas-api-tools/api-tools-skeleton"},
               {"Drest", "https://github.com/leedavis81/drest"},
               {"HAL", "https://github.com/blongden/hal"},
               {"Hateoas", "https://github.com/willdurand/Hateoas"},
               {"Negotiation", "https://github.com/willdurand/Negotiation"},
               {"Restler", "https://github.com/Luracast/Restler"},
               {"wsdl2phpgenerator", "https://github.com/wsdl2phpgenerator/wsdl2phpgenerator"}
             ]
      assert result["Internationalisation and Localisation"] == [
               {"Aura.Intl", "https://github.com/auraphp/Aura.Intl"},
               {"CakePHP I18n", "https://github.com/cakephp/i18n"}
             ]
      assert result["Extensions"] == [{"Zephir", "https://github.com/phalcon/zephir"}]
    end

    test "не должен ничего распарсить, если якорь начала категорий указан неверно" do
      data = File.read!("test/fixtures/awesome-php.html")
      {:ok, result} = ReadmeParser.parse_readme(data, "#awesome-aaa")
      assert result == %{}
    end
  end
end