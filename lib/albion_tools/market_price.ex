defmodule AlbionTools.MarketPrice do

  defstruct items: [], cities: [], price_list: []

  alias AlbionTools.AOData.Api
  alias AlbionTools.MarketPrice
  alias AlbionTools.Items.Item

  def fetch_market_data(items, cities) do
    item_names = Enum.map items, fn item ->
      case item do
        %Item{} -> enchantment_name(item)
        _ -> item
      end
    end
    price_list = Api.fetch_market_data(item_names, cities)
    %MarketPrice{items: items, cities: cities, price_list: price_list}
  end

  defp enchantment_name(item = %Item{}) do
    case Item.get_enchantment_level(item) do
      0 -> item.unique_name
      enchantment_level -> "#{item.unique_name}@#{enchantment_level}"
    end
  end

  def fetch_price(market_price = %MarketPrice{}, item_unique_name, city) do
    Enum.find market_price.price_list, fn price ->
      price["city"] == city && price["item_id"] == item_unique_name
    end
  end

  def fetch_item_prices(market_price = %MarketPrice{}, item_unique_name) do
    Enum.filter market_price.price_list, fn price ->
      price["item_id"] == item_unique_name
    end
  end

  def highest_sell_order(market_price = %MarketPrice{}, item_unique_name) do
    market_price
    |> fetch_item_prices(item_unique_name)
    |> highest_sell_order()
  end

  def second_lowest_sell_order(market_price = %MarketPrice{}, item_unique_name) do

  end

  def average_sell_order(market_price = %MarketPrice{}, item_unique_name) do
    price_list = market_price
    |> fetch_item_prices(item_unique_name)
    |> Enum.map fn price -> price["sell_price_min"] end

    Enum.reduce(price_list, 0, fn x, acc -> x + acc end)/Enum.count(price_list)
  end

  def highest_buy_order(market_price = %MarketPrice{}, item_unique_name) do
    market_price
    |> fetch_item_prices(item_unique_name)
    |> highest_buy_order()
  end

  def lowest_sell_order(market_price = %MarketPrice{}, item_unique_name) do
    market_price
    |> fetch_item_prices(item_unique_name)
    |> lowest_sell_order()
  end

  def lowest_buy_order(market_price = %MarketPrice{}, item_unique_name) do
    market_price
    |> fetch_item_prices(item_unique_name)
    |> lowest_buy_order()
  end

  def highest_sell_order(price_list) do
    Enum.max_by(price_list, &(&1["sell_price_min"]))
  end

  def highest_buy_order(price_list) do
    Enum.max_by(price_list, &(&1["buy_price_max"]))
  end

  def lowest_sell_order(price_list) do
    Enum.min_by(price_list, &(&1["sell_price_min"]))
  end

  def lowest_buy_order(price_list) do
    Enum.min_by(price_list, &(&1["buy_price_max"]))
  end
end
