defmodule TagTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start()
  end

  # TODO: This API endpoint currently gets 500 errors accross the board

  # test "list tags returns empty array when none present" do
  #   use_cassette "tags.list.empty" do
  #     assert [] = Stories.Tag.list()
  #   end
  # end

  # test "list tags" do
  #   use_cassette "tags.list" do
  #     assert [%Stories.Tag{}] = Stories.Tag.list()
  #   end
  # end

  # test "create tags" do
  #   use_cassette "tags.create" do
  #     assert %Stories.Tag{name: "Test tag"} =
  #              Stories.Tag.create(%{
  #                name: "Test tag"
  #              })
  #   end
  # end

  # test "update tag" do
  #   use_cassette "tags.update" do
  #     assert %Stories.Tag{email: "eric@clockk.com", name: "Courtney from \"Your Highness\""} =
  #              Stories.Tag.update("f3111ed7-9372-453e-8838-19ab2de8adc0", %{
  #                name: "Courtney from \"Your Highness\""
  #              })
  #   end
  # end

  # test "delete tag" do
  #   use_cassette "tags.delete" do
  #     assert :ok = Stories.Tag.delete("f3111ed7-9372-453e-8838-19ab2de8adc0")
  #   end
  # end
end
