defmodule AlbionTools.CLI do
  use Artificery

  alias AlbionTools.Crafting
  alias AlbionTools.Items
  alias AlbionTools.Items.Item
  alias AlbionTools.MarketPrice

  @crafting_cities "Bridgewatch,Lymhurst,Fort Sterling,Martlock,Thetford"
  @reference_city "Lymhurst"
  @selling_cities "Black Market,Caerleon"

  @crafting_return_bonus_no_focus 25
  @crafting_return_no_focus 15
  @crafting_return_bonus_focus 44
  @crafting_return_focus 48

  command :import_items, "Import all items from ao-bin-dump repo" do
    argument :file_name, :string, "The location of the file", required: true
  end

  def import_items(_argv, opts) do
    Items.import_file(opts[:file_name])
  end

  command :crafting, "Calculates profits for crafting" do
    argument :item_name, :string, "Name of the item to be crafted", required: true
    option :tax, :int, "Tax price of the station"
    option :buying_cities, :string, "Set the cities you intend to buy materials."
    option :selling_cities, :string, "Set the cities you intend to sell crafted gears."
    option :bonus, :boolean, "When set, consider city with bonus. Default: true"
    option :focus, :boolean, "When set, consider using focus. Default: false"
  end

  def crafting(_argv, opts) do
    item_names = opts[:item_name] |> String.split(",")
    tax = Map.get(opts, :tax, 30)
    return_rate = 0.25
    cities = Map.get(opts, :cities, @crafting_cities) |> String.split(",")
    selling_cities = Map.get(opts, :selling_cities, @selling_cities) |> String.split(",")

    items =
      item_names
      |> Enum.map(fn item_name -> Items.get_resource!(item_name) end)

    mat_prices =
      items
      |> Enum.flat_map(&get_production_items/1)
      |> MarketPrice.fetch_market_data(cities)

    product_prices =
      items
      |> Enum.flat_map(&get_enchanted_items/1)
      |> Enum.concat(item_names)
      |> MarketPrice.fetch_market_data(selling_cities)


    items
    |> Enum.map(fn item -> Crafting.calculate_profits(item, 0, return_rate, cities, product_prices, mat_prices) end)
    |> Enum.reduce(fn x, acc -> x ++ acc end)
    |> Enum.sort_by(&Enum.fetch!(&1, 6), :desc)
    |> normalise_date()
    |> render_crafting_results()
  end

  def get_enchanted_items(item) do
    Item.extract_enchantments(item)
      |> Enum.map(fn enchanted_item ->
        enchantmentlevel = Map.get(enchanted_item, "@enchantmentlevel", "0")
          |> String.to_integer
        "#{item.unique_name}@#{enchantmentlevel}"
      end)
  end

  def get_production_items(item) do
    resources =
      Item.extract_crafting_resources(item)
      |> Enum.map(fn x -> Items.get_resource!(Map.get x, "@uniquename") end)
    enchanted_resources =
      Item.extract_enchanted_crafting_resources(item)
      |> Enum.map(fn x -> Items.get_resource!(Map.get x, "@uniquename") end)

    Enum.concat(resources, enchanted_resources)
  end

  def normalise_date(rows) do
    Enum.map rows, fn row ->
      date_diff = DateTime.diff(DateTime.now!("Etc/UTC"), Enum.fetch!(row, 7))
      List.replace_at(row, 7, Float.round(date_diff/60/60, 2))

    end
  end

  def render_crafting_results(rows) do
    header = ["Item", "% of a book", "Value of Book", "Break Even", "Sell Order", "Material Required", "Profit", "Last Update (hours)"]
    TableRex.quick_render!(rows, header)
    |> IO.puts
  end
end
