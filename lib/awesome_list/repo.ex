defmodule AwesomeList.Repo do
  use Ecto.Repo,
    otp_app: :awesome_list,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Обновить запись
  """
  def reload(%module{id: id}) do
    get(module, id)
  end
end
