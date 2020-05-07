defmodule StoriesTest do
  use ExUnit.Case
  doctest Stories
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start()
  end

  test "list users returns empty array when none present" do
    use_cassette "users.list.empty" do
      assert [] = Stories.User.list()
    end
  end

  test "create users" do
    use_cassette "users.create" do
      assert %Stories.User{email: "eric@clockk.com"} =
               Stories.User.create(%{
                 user_id: "b0dbfb1d-fcab-4a27-9193-82b2c55e0675",
                 name: "Eric Froese",
                 email: "eric@clockk.com"
               })
    end
  end
end
