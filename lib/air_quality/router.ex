defmodule AirQuality.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Poison,
    body_reader: Clova.CachingBodyReader.spec()

  plug Clova.Validator,
    app_id: "com.line-apps.air_quality",
    force_signature_valid: Application.get_env(:air_quality, :force_signature_valid)

  plug Clova.Dispatcher, dispatch_to: AirQuality
  plug :match
  plug :dispatch

  post "/clova" do
    send_resp(conn)
  end

  match("/clova", do: send_resp(conn, :method_not_allowed, ""))
  match(_, do: send_resp(conn, :not_found, ""))

  def handle_errors(conn, %{kind: :error, reason: reason}) do
    send_resp(conn, conn.status, Exception.message(reason))
  end
end
