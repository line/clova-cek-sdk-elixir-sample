defmodule RouterTest do
  use ExUnit.Case
  use Plug.Test

  # We cannot generate a valid signed request ourselves, so use an actual request taken from the server logs
  @json ~S({"version":"1.0","session":{"new":true,"sessionAttributes":{},"sessionId":"e7b804f0-8e61-4fde-bbf7-68af4fd923e1","user":{"userId":"Ub72f92a3cf285843ccdf628a1761c04e"}},"context":{"System":{"application":{"applicationId":"com.line-apps.air_quality"},"device":{"deviceId":"90f832998db77f4d1232df49faa330c07e9d8db5ed9c3cd1bbc7f8fa9f7bf1e9","display":{"size":"none","contentLayer":{"width":0,"height":0}}},"user":{"userId":"Ub72f92a3cf285843ccdf628a1761c04e"}}},"request":{"type":"LaunchRequest","requestId":"5a428858-4e34-4851-a4b9-80518c851b0b","timestamp":"2018-07-10T05:31:34Z","locale":"ja-JP","extensionId":"com.line-apps.air_quality","intent":{"intent":"","name":"","slots":null},"event":{"namespace":"","name":"","payload":null}}})

  @signature "KHbJrrWcIvGjHFj8cvVtugNMcRUkYhGNw6MaGjS81h/JJd2pgsgNCevmLMpiyjpm5vQq3sZrajLiD6kUKvYAeAxdH5ICr3GbdrqJYKVwQm2pxIdImdnBealwf528czuOKO21IFDAQRdmJG6B5Cxx8/0VtALX3vqT/pywA0LaeggmpOFuOjaDGpJ0tpAUKjVv+H7O5/yX6X9IFvj1nxP+thcMTNlY5MFbO0mjXvRzZjqerD1kapRIHlTD4kZyc/0OtUWR7qFvujSsarkZbfTvT+WwqJsKqDIRWAtH8c/cnfs/quZwuXm+80o7ZKJm0u5rp+sHt4XKTP1BL+iamr2A/A=="

  test "Post to /clova is without signature returns 403" do
    conn = conn(:post, "/clova", @json) |> put_req_header("content-type", "application/json")

    conn = AirQuality.Router.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 403
  end

  test "Post to /clova returnexs successful response when validated" do
    conn =
      conn(:post, "/clova", @json)
      |> put_req_header("content-type", "application/json")
      |> put_req_header("signaturecek", @signature)

    conn = AirQuality.Router.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]
  end
end
