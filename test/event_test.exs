defmodule EventTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start()
  end

  test "create events" do
    use_cassette "events.create" do
      assert %Stories.Event{name: "A developer tested the Elixir Stories API wrapper"} =
               Stories.Event.create(%{
                 user_id: "f3111ed7-9372-453e-8838-19ab2de8adc0",
                 name: "A developer tested the Elixir Stories API wrapper",
                 data:
                   Jason.encode!(%{
                     clockk_info: "This is some data related to clockk",
                     format:
                       "JSON is the format of this data. The API calls for a string. I wonder how it handles this data when it displays it in the interface"
                   })
               })
    end
  end
end
