defmodule AlbionTools.Crafting do

  alias AlbionTools.Items
  alias AlbionTools.Items.Item
  alias AlbionTools.Journals
  alias AlbionTools.MarketPrice

  @base_fame %{
    "4" => 22.5,
    "5" => 90,
    "6" => 270,
    "7" => 645,
    "8" => 1395
  }

  def lowest_bm_value(product_prices, unique_name) do
    lowest_value = MarketPrice.fetch_price(product_prices, unique_name, "Black Market")

    type = case lowest_value["sell_price_min"] do
      0 -> "buy_price_max"
      _ -> "sell_price_min"
    end

    {type, lowest_value[type], lowest_value[type <> "_date"]}
  end

  def calculate_profits(item, fee, return_rate, cities, selling_cities) do
    enchantments = Item.extract_enchantments(item)
    model = %{
      item: item.unique_name,
      crafting_materials: Item.extract_crafting_resources(item)
    }

    resources = model.crafting_materials
      |> Enum.map(fn x -> Items.get_resource!(Map.get x, "@uniquename") end)
    enchanted_resources = Item.extract_enchanted_crafting_resources(item)
      |> Enum.map(fn x -> Items.get_resource!(Map.get x, "@uniquename") end)

    product_prices = MarketPrice.fetch_market_data([item], selling_cities)
    resources
      |> Enum.concat(enchanted_resources)
    mat_prices = MarketPrice.fetch_market_data(resources |> Enum.concat(enchanted_resources), cities)

    empty_journal = Journals.empty_unique_name(item)
    full_journal = Journals.full_unique_name(item)

    journal_prices = MarketPrice.fetch_market_data([empty_journal, full_journal], cities)

    actual_book = calc_actual_book(item, 0)
    {_, mat_cost} = Enum.map_reduce(model.crafting_materials, 0, fn mat, acc ->
      {mat, acc + String.to_integer(mat["@count"]) * MarketPrice.highest_buy_order(mat_prices, mat["@uniquename"])["buy_price_max"]}
    end)

    single_book_value = MarketPrice.average_sell_order(journal_prices, full_journal)
    price_book = floor(actual_book * single_book_value)
    {type, bm_value, bm_date} = lowest_bm_value(product_prices, item.unique_name)
    {:ok, black_market_date, 0} = DateTime.from_iso8601(bm_date <> "Z")
    revenue = bm_value + price_book
    expenses = Journals.get_journal_price(Item.get_tier(item)) + mat_cost*(1-return_rate) + floor(0.045*revenue)
    break_even = expenses - price_book

    [[
      item.unique_name,
      actual_book,
      "#{price_book} (#{single_book_value})",
      break_even,
      "#{bm_value} (#{type})",
      mat_cost,
      revenue - expenses,
      black_market_date
    ]] ++ calculate_enchantment(item, 0, return_rate, mat_prices, journal_prices)

  end

  def calculate_enchantment(item, fee, return_rate, mat_prices, journal_prices) do
    full_journal = Journals.full_unique_name(item)

    Item.extract_enchantments(item)
    |> Enum.map(fn enchanted_item ->
      enchantmentlevel = Map.get(enchanted_item, "@enchantmentlevel", "0")
        |> String.to_integer
      actual_book = calc_actual_book(item, enchantmentlevel)
      unique_name = "#{item.unique_name}@#{enchantmentlevel}"
      product_prices = MarketPrice.fetch_market_data([unique_name], ["Black Market"])

      mat = enchanted_item["craftingrequirements"]["craftresource"]
      mat_cost = String.to_integer(mat["@count"]) * MarketPrice.highest_buy_order(mat_prices, "#{mat["@uniquename"]}@#{mat["@enchantmentlevel"]}")["buy_price_max"]

      single_book_value = MarketPrice.average_sell_order(journal_prices, full_journal)
      price_book = floor(actual_book * single_book_value)
      {type, bm_value, bm_date} = lowest_bm_value(product_prices, unique_name)
      {:ok, black_market_date, 0} = DateTime.from_iso8601(bm_date <> "Z")
      revenue = bm_value + price_book
      expenses = Journals.get_journal_price(Item.get_tier(item)) + mat_cost*(1-return_rate) + floor(0.045*revenue)
      break_even = expenses - price_book

      [
        unique_name,
        actual_book,
        "#{price_book} (#{single_book_value})",
        break_even,
        "#{bm_value} (#{type})",
        mat_cost,
        revenue - expenses,
        black_market_date
      ]
    end)
  end

  def calc_actual_book(item, enchantmentlevel) do
    fame = base_fame(item) + artifact_value(item) + enchantment_value(item, enchantmentlevel)
    fame / Journals.get_fame_required(item)
  end

  defp enchantment_value(item, enchantment_level) do
    enchantment_level * (base_fame(item) - 7.5 * Item.amount_material(item))
    |> floor()
  end

  def artifact_value(item) do
    0
  end

  defp base_fame(item) do
    Item.amount_material(item) * Map.get(@base_fame, Item.get_tier(item), 0)
  end
end
