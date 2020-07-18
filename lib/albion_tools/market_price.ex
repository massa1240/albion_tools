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

  def fetch_market_data(items, cities) do
    price_list = Api.fetch_market_data(items, cities)
    %MarketPrice{items: items, cities: cities, price_list: price_list}
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

  def higher_sell_order(market_price = %MarketPrice{}, item_unique_name) do
    market_price
    |> fetch_item_prices(item_unique_name)
    |> higher_sell_order()
  end

  def higher_buy_order(market_price = %MarketPrice{}, item_unique_name) do
    market_price
    |> fetch_item_prices(item_unique_name)
    |> higher_buy_order()
  end

  def lower_sell_order(market_price = %MarketPrice{}, item_unique_name) do
    market_price
    |> fetch_item_prices(item_unique_name)
    |> lower_sell_order()
  end

  def lower_buy_order(market_price = %MarketPrice{}, item_unique_name) do
    market_price
    |> fetch_item_prices(item_unique_name)
    |> lower_buy_order()
  end

  def higher_sell_order(price_list) do
    Enum.max_by(price_list, &(&1["sell_price_min"]))
  end

  def higher_buy_order(price_list) do
    Enum.max_by(price_list, &(&1["buy_price_min"]))
  end

  def lower_sell_order(price_list) do
    Enum.min_by(price_list, &(&1["sell_price_min"]))
  end

  def lower_buy_order(price_list) do
    Enum.min_by(price_list, &(&1["buy_price_min"]))
  end
end
