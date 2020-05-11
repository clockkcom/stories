defmodule AttributeTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start()
  end

  test "list attributes returns empty array when none present" do
    use_cassette "attributes.list.empty" do
      assert [] = Stories.Attribute.list()
    end
  end

  test "list attributes" do
    use_cassette "attributes.list" do
      assert [%Stories.Attribute{} | _] = Stories.Attribute.list()
    end
  end

  test "create attributes" do
    use_cassette "attributes.create" do
      assert %Stories.Attribute{name: "Admin"} =
               Stories.Attribute.create(%{name: "Admin", data_type: "boolean"})
    end
  end

  test "delete attribute" do
    use_cassette "attributes.delete" do
      assert :ok = Stories.Attribute.delete("123")
    end
  end
end
