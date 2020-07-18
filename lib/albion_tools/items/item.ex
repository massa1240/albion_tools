defmodule AlbionTools.Items.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "items" do
    field :meta, :map
    field :unique_name, :string

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:unique_name, :meta])
    |> validate_required([:unique_name, :meta])
  end

  def get_tier(item) do
    Map.get item.meta, "@tier"
  end

  def get_enchantment_level(item) do
    Map.get item.meta, "@enchantmentlevel", 0
  end

  def extract_crafting_resources(item) do
    item.meta["craftingrequirements"]
    |> Enum.flat_map(fn x -> x["craftresource"] end)
  end

  def extract_enchantments(item) do
    item.meta["enchantments"]["enchantment"]
  end

  def extract_enchanted_crafting_resources(item) do
    extract_enchantments(item)
    |> Enum.map(fn x -> x["craftingrequirements"] end)
    |> Enum.map(fn x -> x["craftresource"] end)
  end

  def amount_material(item) do
    extract_crafting_resources(item)
      |> Enum.map(fn el -> Map.get(el, "@count") end)
      |> Enum.reduce(0, fn x, acc -> acc + String.to_integer(x) end)
  end


end
