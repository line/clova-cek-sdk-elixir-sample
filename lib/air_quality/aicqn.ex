defmodule AICQN do
  defstruct [:station, :aqi, :level, :implications]

  def search(city) do
    city = Regex.replace(~r/市\z/, city, "")
    query = URI.encode_query(keyword: city, token: System.get_env("AICQN_TOKEN"))

    data =
      URI.parse("http://api.waqi.info/search/")
      |> Map.put(:query, query)
      |> URI.to_string()
      |> HTTPoison.get!()
      |> Map.get(:body)
      |> Poison.decode!()
      |> Map.get("data")

    case data do
      [%{"aqi" => aqi, "station" => %{"name" => name}} | _tail] ->
        {:ok, for_station_index(name, aqi)}

      [] ->
        :empty
    end
  end

  defp for_station_index(station, aqi) do
    # don't need anything after ;
    [station | _] = String.split(station, ";")

    result = %AICQN{station: station}

    sensitive = "心臓・肺疾患患者、高齢者及び子供"

    case Integer.parse(aqi) do
      {aqi, _} when aqi in 0..50 ->
        %AICQN{result | aqi: aqi, level: "良い", implications: "通常の活動が可能"}

      {aqi, _} when aqi in 51..100 ->
        %AICQN{result | aqi: aqi, level: "許容範囲", implications: "特に敏感な者は、長時間又は激しい屋外活動の減少を検討"}

      {aqi, _} when aqi in 101..150 ->
        %AICQN{
          result
          | aqi: aqi,
            level: "敏感なグループにとっては健康に良くない",
            implications: "#{sensitive}は、長時間又は激しい屋外活動を減少"
        }

      {aqi, _} when aqi in 151..200 ->
        %AICQN{
          result
          | aqi: aqi,
            level: "健康に良くない",
            implications: "#{sensitive}は長時間又は激しい屋外活動を中止。すべての者は、長時間又は激しい屋外活動を減少"
        }

      {aqi, _} when aqi in 201..300 ->
        %AICQN{
          result
          | aqi: aqi,
            level: "極めて健康に良くない",
            implications: "#{sensitive}はすべての屋外活動を中止。 すべての者は、長時間又は激しい屋外活動を中止"
        }

      {aqi, _} when aqi > 300 ->
        %AICQN{
          result
          | aqi: aqi,
            level: "危険",
            implications: "#{sensitive}は、屋内に留まり、体力消耗を避ける。 すべての者は、屋外活動を中止"
        }

      _ ->
        %AICQN{result | aqi: "不明です", level: "結果をわからない", implications: "結果をわからない"}
    end
  end
end
