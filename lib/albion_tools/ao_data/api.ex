defmodule AlbionTools.AOData.Api do

  @base "https://www.albion-online-data.com/api/v1/stats/prices"
  @headers [
    {"content-type", "application/json"},
    {"accept", "text/html,application/json"}
  ]

  def fetch_market_data(items, cities) do
    url = "#{@base}/#{join_list(Enum.uniq(items))}"

    HTTPoison.start
    HTTPoison.get!(url, @headers, params: %{qualities: 0, locations: join_list(Enum.uniq(cities))}).body
    |> Poison.decode!
  end

  def join_list(list) do
    list
    |> Enum.join(",")
  end
end
