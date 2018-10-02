# AirQuality

Example Clova Extension using the Clova SDK.

## Router definition

The [router](lib/air_quality/router.ex) uses [`Clova.SkillPlug`](https://hexdocs.pm/clova/Clova.SkillPlug.html), and simply returns the connection object.

```
  plug Clova.SkillPlug,
    dispatch_to: AirQuality,
    app_id: "com.line-apps.air_quality",
    json_module: Poison
  plug :match
  plug :dispatch

  post "/clova" do
    send_resp(conn)
  end
```

## Callback implementation

The main Clova behaviour is implemented by the [`AirQuality`](lib/air_quality.ex) module.

```
  def handle_launch(_request, response) do
    response
    |> add_speech("大気汚染を知りたい都市名を言ってください")
    |> add_reprompt("都市の名前を言ったら大気汚染情報を調べますよ")
  end
```
