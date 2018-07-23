defmodule AICQN.InMemory do
  def search(city) when city == "known" do
    {:ok, %AICQN{station: "known", aqi: 40, level: "ok"}}
  end

  def search(city) when city == "empty" do
    :empty
  end
end
