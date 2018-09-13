defmodule AirQualityTest do
  use ExUnit.Case
  doctest AirQuality
  alias Clova.Response

  test "handle_launch creates launch response" do
    envelope = AirQuality.handle_launch(nil, %Response{})
    assert envelope.response.outputSpeech.values.value == "大気汚染を知りたい都市名を言ってください"
  end

  test "handle_intent creates didn't understand response for unknown intent" do
    envelope = AirQuality.handle_intent("foo", nil, %Response{})
    [speech1, speech2] = envelope.response.outputSpeech.values
    assert speech1.value == "すみません。リクエストをわかりませんでした"
    assert speech2.value == "大気汚染を知りたい都市名を言ってください"
  end

  test "handle_intent complains and creates launch response if no city provided" do
    request = make_request(nil)

    response = AirQuality.handle_intent("particulateMatter", request, %Response{})

    [error, launch] = response.response.outputSpeech.values
    assert error.value === "すみません。街の名前をわかりませんでした。"
    assert launch.value === "大気汚染を知りたい都市名を言ってください"
  end

  test "handle_intent gets the polution level for a known city" do
    request = make_request(%{"city" => %{"name" => "city", "value" => "known"}})
    response = AirQuality.handle_intent("particulateMatter", request, %Response{})

    assert response.response.outputSpeech.values.value == "known市の大気汚染はokです。たいきしつ指数は40です。"

    assert response.response.shouldEndSession
  end

  test "handle intent says it doesn't understand and ends the session for an unknown city" do
    request = make_request(%{"city" => %{"name" => "city", "value" => "empty"}})

    response = AirQuality.handle_intent("particulateMatter", request, %Response{})

    assert response.response.outputSpeech.values.value == "すみませんemptyの情報を見つけられませんでした。"
    refute response.response.shouldEndSession
  end

  test "handle_session_ended creates ignored response" do
    expected = %Response{}
    actual = AirQuality.handle_session_ended(nil, expected)
    assert expected == actual
  end

  defp make_request(slots) do
    %{
      "request" => %{"intent" => %{"name" => "particulateMatter", "slots" => slots}},
      "session" => %{"sessionAttributes" => %{"foo" => "bar"}},
      "context" => %{"System" => %{"application" => %{"applicationId" => "test_app_id"}}}
    }
  end
end
