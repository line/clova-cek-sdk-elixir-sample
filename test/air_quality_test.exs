defmodule AirQualityTest do
  use ExUnit.Case
  doctest AirQuality
  alias Clova.{Request, Response}

  test "handle_launch creates launch response" do
    envelope = AirQuality.handle_launch(%Request{}, %Response{})
    assert envelope.response.outputSpeech.values.value == "大気汚染を知りたい都市名を言ってください"
  end

  test "handle_intent creates didn't understand response for unknown intent" do
    envelope = AirQuality.handle_intent("foo", nil, %Response{})
    [speech1, speech2] = envelope.response.outputSpeech.values
    assert speech1.value == "すみません。リクエストをわかりませんでした"
    assert speech2.value == "大気汚染を知りたい都市名を言ってください"
  end

  test "handle_intent creates launch response if no city provided" do
    request_envelope = make_request(nil)

    response_envelope =
      AirQuality.handle_intent("particulateMatter", request_envelope, %Response{})

    assert response_envelope.response.outputSpeech.values.value == "大気汚染を知りたい都市名を言ってください"
  end

  test "handle_intent gets the polution level for a known city" do
    request_envelope = make_request(%{"city" => %{"name" => "city", "value" => "known"}})

    response_envelope =
      AirQuality.handle_intent("particulateMatter", request_envelope, %Response{})

    assert response_envelope.response.outputSpeech.values.value ==
             "known市の大気汚染はokです。たいきしつ指数は40です。"

    assert response_envelope.response.shouldEndSession
  end

  test "handle intent says it doesn't understand and ends the session for an unknown city" do
    request_envelope = make_request(%{"city" => %{"name" => "city", "value" => "empty"}})

    response_envelope =
      AirQuality.handle_intent("particulateMatter", request_envelope, %Response{})

    assert response_envelope.response.outputSpeech.values.value == "すみませんemptyの情報を見つけられませんでした。"
    refute response_envelope.response.shouldEndSession
  end

  test "handle_session_ended creates ignored response" do
    expected = %Response{}
    actual = AirQuality.handle_session_ended(%Request{}, expected)
    assert expected == actual
  end

  defp make_request(slots) do
    %Request{
      request: %Request.Request{
        intent: %Request.Intent{
          name: "particulateMatter",
          slots: slots
        }
      }
    }
  end
end
