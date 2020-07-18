defmodule AlbionTools.Items do

  def extract_shopcategory(item) do
    Map.get(item.meta, "@shopcategory")
  end

  @moduledoc """
  The Items context.
  """

  import Ecto.Query, warn: false
  alias AlbionTools.Repo

  alias AlbionTools.Items.Item

  def import_file(file_name) do
    Poison.decode!(File.read!(file_name))
    |> Map.fetch!("items")
    |> fetch_keys(["equipmentitem", "simpleitem"])
    |> Enum.filter(&find_importable/1)
    |> Enum.map(&fix_crafting_json/1)
    |> Enum.each(fn x ->
      %{"unique_name" => Map.get(x, "@uniquename"), "meta" => x}
      |> create_resource()
    end)
  end

  def fix_crafting_json(item_json) do
    item_json
    |> fix_craftingrequirements()
    |> fix_craftresource()
  end

  def fix_craftingrequirements(item_json) do
    cond do
      is_map(Map.fetch!(item_json, "craftingrequirements")) ->
        craftingrequirements = [item_json["craftingrequirements"]]
        put_in(item_json, Enum.map(["craftingrequirements"], &Access.key(&1, %{})), craftingrequirements)
      true ->
        item_json
    end
  end

  def fix_craftresource(item_json) do
    craftingrequirements = Map.fetch!(item_json, "craftingrequirements")
      |> Enum.map(&fix_craftresource_from_requirement/1)

    put_in(item_json, Enum.map(["craftingrequirements"], &Access.key(&1, %{})), craftingrequirements)
  end

  def fix_craftresource_from_requirement(craftingrequirement) do
    cond do
      is_map(Map.get(craftingrequirement, "craftresource")) ->
        craftresource = [craftingrequirement["craftresource"]]
        put_in(craftingrequirement, Enum.map(["craftresource"], &Access.key(&1, %{})), craftresource)
      true ->
        craftingrequirement
    end
  end

  def fetch_keys(items_json, key_list) do
    key_list
    |> Enum.flat_map(fn x -> Map.fetch! items_json, x end)
  end

  def find_importable(item_json) do
    importable = ["resources", "armor", "accessories"]
    Enum.any?(importable, fn x -> x == Map.get(item_json, "@shopcategory") && Map.get(item_json, "craftingrequirements") end)
  end

  @doc """
  Returns the list of resources.

  ## Examples

      iex> list_resources()
      [%Item{}, ...]

  """
  def list_resources do
    Repo.all(Item)
  end

  @doc """
  Gets a single resource.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_resource!(123)
      %Item{}

      iex> get_resource!(456)
      ** (Ecto.NoResultsError)

  """
  def get_resource!(id) do
    query = from r in Item,
      where: r.unique_name == ^id

    Repo.one!(query)
  end

  @doc """
  Creates a resource.

  ## Examples

      iex> create_resource(%{field: value})
      {:ok, %Item{}}

      iex> create_resource(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_resource(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a resource.

  ## Examples

      iex> update_resource(resource, %{field: new_value})
      {:ok, %Item{}}

      iex> update_resource(resource, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_resource(%Item{} = resource, attrs) do
    resource
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a resource.

  ## Examples

      iex> delete_resource(resource)
      {:ok, %Item{}}

      iex> delete_resource(resource)
      {:error, %Ecto.Changeset{}}

  """
  def delete_resource(%Item{} = resource) do
    Repo.delete(resource)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking resource changes.

  ## Examples

      iex> change_resource(resource)
      %Ecto.Changeset{source: %Item{}}

  """
  def change_resource(%Item{} = resource) do
    Item.changeset(resource, %{})
  end
end
