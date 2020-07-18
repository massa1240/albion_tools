defmodule AlbionTools.Journals do

  alias AlbionTools.Items.Item

  @prices %{
    "2" => 500,
    "3" => 1000,
    "4" => 2000,
    "5" => 4000,
    "6" => 8000,
    "7" => 16000,
    "8" => 32000
  }

  @material_return_rate %{
    "2" => 38,
    "3" => 24,
    "4" => 16,
    "5" => 8,
    "6" => 5.3333,
    "7" => 4.4651,
    "8" => 4.129
  }

  @fame_required %{
    "2" => 300,
    "3" => 600,
    "4" => 1200,
    "5" => 2400,
    "6" => 4800,
    "7" => 9600,
    "8" => 19200
  }

  def get_journal_price(tier) do
    @prices[tier]
  end

  def get_fame_required(item = %Item{}) do
    @fame_required[Item.get_tier(item)]
  end

  def get_fame_required(tier) do
    @fame_required[tier]
  end

  def empty_unique_name(item) do
    unique_name(item, "EMPTY")
  end

  def full_unique_name(item) do
    unique_name(item, "FULL")
  end

  defp unique_name(item, suffix) do
    item_split = String.split(item.unique_name, "_")
    "T#{Map.get(item.meta, "@tier")}_JOURNAL_#{journal_type(item_split)}_#{suffix}"
  end

  defp journal_type(item_split) do
    case item_split do
      [_, _, "CLOTH", _] ->
        "MAGE"
      [_, _, "LEATHER", _] ->
        "HUNTER"
      [_, _, "PLATE", _] ->
        "WARRIOR"
      _ ->
        "TOOLMAKER"
    end
  end
end
