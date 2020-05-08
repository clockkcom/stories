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

  test "list users" do
    use_cassette "users.list" do
      assert [%Stories.User{}] = Stories.User.list()
    end
  end

  test "create users" do
    use_cassette "users.create" do
      assert %Stories.User{email: "eric@clockk.com"} =
               Stories.User.create(%{
                 user_id: "b0dbfb1d-fcab-4a27-9193-82b2c55e0675",
                 email: "eric@clockk.com"
               })
    end
  end

  test "update user" do
    use_cassette "users.update" do
      assert %Stories.User{email: "eric@clockk.com", name: "Courtney from \"Your Highness\""} =
               Stories.User.update("f3111ed7-9372-453e-8838-19ab2de8adc0", %{
                 name: "Courtney from \"Your Highness\""
               })
    end
  end

  test "delete user" do
    use_cassette "users.delete" do
      assert :ok = Stories.User.delete("f3111ed7-9372-453e-8838-19ab2de8adc0")
    end
  end
end
