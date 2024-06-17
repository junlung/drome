defmodule Drome.Repo do
  use Ecto.Repo,
    otp_app: :drome,
    adapter: Ecto.Adapters.Postgres

  use Scrivener
end
