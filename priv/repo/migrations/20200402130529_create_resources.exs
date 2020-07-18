defmodule Albionsim.Repo.Migrations.CreateResources do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :unique_name, :string
      add :meta, :map

      timestamps()
    end

  end
end
