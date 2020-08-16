# AwesomeList

Инсталляция стандартная - ожидается, что установлены `elixir` не старше 1.9 версии, `mix` и `postgresql`.

Запуск:
  * зависимости - `mix deps.get`
  * подготовка БД - `mix ecto.setup`
  * сборка ассетов - `npm install --prefix assets`
  * и запуск - `mix phx.server`

В браузере открываем [`localhost:4000`](http://localhost:4000).

Чтобы вручную запустить парсинг README указанных репозиториев, в консоли вызываем:
```
AwesomeList.Repo.Performer.handle_info(:work, %{})
```

По умолчанию, при запуске ставится ожидание выполнения через сутки, с самоповтором.

## Демо

можно потыкать [тут](https://damp-earth-55473.herokuapp.com/)

## Особенности
Поддерживается множество разных списков (проверены elixir, php, ruby). Парсер README использует данные html, т.к. из
markdown, полученного по api, унифицированный парсер сделать проблематично.
Чтобы добавить новый список, нужно:
```
AwesomeList.Repo.Languages.create_language(%{name: "php", repo_path: "ziadoz/awesome-php", list_anchor: "#awesome-php"})
```
где `name` - имя языка, `repo_path` - username + reponame из гитхаба, `list_anchor` - якорь на странице readme, 
он нужен чтобы корректно инициировать парсер.

Далее, асинхронно опрашиваются репозитории из категорий.
Тут есть тонкость: запросы по api без авторизации ограничены 60 в час - этого мало. Поэтому используется просто пустая
учётка, оттуда берём пару client_id/client_secret. С этим мы вроде как ограничены 5000 запросов в месяц (хотя и тут всё не так однозначно).
В общем, обновление ежедневно могут в один момент отвалиться просто потому что мы упрёмся в ограничения github api.
Решение - либо "размазывать" запросы во времени, либо обновление проводить реже, раз в неделю например (при этом, 
каждый отдельный список надо шедулить в разное время), либо заводить N учёток гитхаба и организовывать пул.

# TODO
1. Сейчас есть библиотеки, которые встречаются в разных категориях.
Из-за индекса libraries_name_category_id_index запрос не проходит и категория не сохраняется.
Решение простое: нужно сделать множественную связь с categories. 
2. нужны тесты на Presenter