defmodule AlbionTools.Repo do
  use Ecto.Repo,
    otp_app: :albion_tools,
    adapter: Ecto.Adapters.Postgres
end
