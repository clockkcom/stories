defmodule TagTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start()
  end

  test "list tags returns empty array when none present" do
    use_cassette "tags.list.empty" do
      assert [] = Stories.Tag.list()
    end
  end

  test "list tags" do
    use_cassette "tags.list" do
      assert [%Stories.Tag{} | _] = Stories.Tag.list()
    end
  end

  test "create tags" do
    use_cassette "tags.create" do
      assert %Stories.Tag{name: "Test tag"} =
               Stories.Tag.create(%{
                 name: "Test tag"
               })
    end
  end

  test "update tag" do
    use_cassette "tags.update" do
      assert %Stories.Tag{name: "Updated test tag"} =
               Stories.Tag.update("14", %{
                 name: "Updated test tag"
               })
    end
  end

  test "delete tag" do
    use_cassette "tags.delete" do
      assert :ok = Stories.Tag.delete("14")
    end
  end

  test "assign_remote raises error with invalid opts" do
    assert_raise StoriesError, fn ->
      Stories.Tag.assign_remove(%Stories.Tag{slug: "test_tag"}, %{assign: :bar})
    end
  end

  # TODO: restore this test when it stops returning 301
  # test "assign tag to user returns tag" do
  #   # use_cassette "tags.assign" do
  #   assert %Stories.Tag{} =
  #            Stories.Tag.assign_remove(%Stories.Tag{slug: "test_tag"}, %{
  #              assign: [
  #                %{
  #                  id: "c100b5c8-048f-41ab-b9dd-09aa889906c0"
  #                }
  #              ]
  #            })

  #   # end
  # end

  test "assign tag by id to user returns tag" do
    use_cassette "tags.assign.by_id" do
      assert %Stories.Tag{} =
               Stories.Tag.assign_remove(%Stories.Tag{id: 15}, %{
                 assign: [
                   %{
                     id: "c100b5c8-048f-41ab-b9dd-09aa889906c0"
                   }
                 ]
               })
    end
  end
end
