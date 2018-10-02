defmodule AirQuality do
  @aicqn_api Application.get_env(:air_quality, :aiqcn_api)
  use Clova

  def handle_launch(_request, response) do
    response
    |> add_speech("大気汚染を知りたい都市名を言ってください")
    |> add_reprompt("都市の名前を言ったら大気汚染情報を調べますよ")
  end

  def handle_intent("particulateMatter", request, response) do
    city = get_slot(request, "city")
    IO.inspect(city, label: "requested city")

    if city do
      case @aicqn_api.search(city) do
        :empty ->
          add_speech(response, "すみません#{city}の情報を見つけられませんでした。")

        {:ok, aqicn = %AICQN{}} ->
          explanation =
            case get_session_attributes(request)["detailedMode"] do
              true -> aqicn.implications
              _ -> aqicn.level
            end

          response
          |> add_speech("#{aqicn.station}市の大気汚染は#{explanation}です。たいきしつ指数は#{aqicn.aqi}です。")
          |> end_session
      end
    else
      response = add_speech(response, "すみません。街の名前をわかりませんでした。")
      handle_launch(request, response)
    end
  end

  def handle_intent("detailedMode", _request, response) do
    response
    |> put_session_attributes(%{"detailedMode" => true})
    |> add_speech("これからたいきしつ指数とともに細かい説明をします")
    |> add_speech("どこの都市の情報を調べましょうか？")
    |> add_reprompt("大気汚染を知りたい都市名を言ってください")
  end

  def handle_intent("Clova.GuideIntent", _request, response) do
    response
    |> add_speech("大気汚染を知りたい都市の名前を言ってください")
    |> add_speech("たいきしつ指数より詳しい説明欲しい時に「詳しく教えてください」を言ってください")
  end

  def handle_intent(_name, request, response) do
    IO.inspect(request)

    response
    |> add_speech("すみません。リクエストをわかりませんでした")
    |> add_speech("大気汚染を知りたい都市名を言ってください")
  end

  def handle_session_ended(_request, response) do
    response
  end
end
