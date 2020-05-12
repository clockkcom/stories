defmodule Stories.Tag do
  use Stories.Resource

  defstruct [
    :id,
    :name,
    :slug
  ]

  defp resource, do: "tags"

  @doc """
  This lets you assign (and/or remove) a tag to multiple users at once. If the tag does not already exist, it will be created for you.

  Example:

      iex> Stories.Tag.assign_remove(
      ...> %Stories.Tag{slug: "test_tag"},
      ...> %{
      ...>  assign: [
      ...>      %{
      ...>        id: "f3111ed7-9372-453e-8838-19ab2de8adc0"
      ...>      }
      ...>    ],
      ...>  remove: [
      ...>      %{
      ...>        user_id: "b0dbfb1d-fcab-4a27-9193-82b2c55e0675"
      ...>      }
      ...>    ],
      ...>  }
      ...> )
      iex> %Stories.Tag{ id: 14, name: "Test Tag", slug: "test_tag" }
  """
  def assign_remove(tag, options)

  def assign_remove(tag = %Stories.Tag{}, %{assign: assign, remove: remove}) do
    assign_valid? =
      case assign do
        [%{user_id: _}] -> true
        [%{id: _}] -> true
        [] -> true
        _ -> false
      end

    remove_valid? =
      case remove do
        [%{user_id: _}] -> true
        [%{id: _}] -> true
        [] -> true
        _ -> false
      end

    if remove_valid? && assign_valid? do
      url =
        "#{api_url()}/#{resource_path()}"
        |> (fn url ->
              if is_nil(tag.id) do
                url
              else
                "#{url}/#{tag.id}"
              end
            end).()

      tag_params =
        [{:name, tag.name}, {:slug, tag.slug}]
        |> Enum.filter(fn {key, val} ->
          !is_nil(val)
        end)
        |> Map.new()

      assign_users =
        Enum.map(assign, fn a_user ->
          [{:id, Map.get(a_user, :id)}, {:user_id, Map.get(a_user, :user_id)}]
          |> Enum.filter(fn {key, val} ->
            !is_nil(val)
          end)
          |> Map.new()
        end)

      remove_users =
        Enum.map(remove, fn r_user ->
          [{:id, Map.get(r_user, :id)}, {:user_id, Map.get(r_user, :user_id)}]
          |> Enum.filter(fn {key, val} ->
            !is_nil(val)
          end)
          |> Map.new()
          |> Map.put(:untag, true)
        end)

      body =
        Map.merge(tag_params, %{
          users: assign_users ++ remove_users
        })

      case HTTPoison.post(
             url,
             Jason.encode!(body),
             Stories.Resource.get_auth_headers() ++ [{"Content-Type", "application/json"}]
           ) do
        {:ok, resp = %HTTPoison.Response{body: resource}} ->
          resource = Jason.decode!(resource, keys: :atoms)

          struct!(__MODULE__, resource)

        {:error, %HTTPoison.Response{status_code: 422, body: body}} ->
          {:error, Jason.decode!(body)}

        {:error, %HTTPoison.Error{reason: reason}} ->
          raise(StoriesError, "Error: #{inspect(reason)}")
      end
    else
      raise(
        StoriesError,
        "Invalid second parameter. Must be a list of maps with keys `:user_id` (the id you attached to the user on creation) or `:id` (the stories id associated with the user)"
      )
    end
  end

  def assign_remove(tag = %Stories.Tag{}, %{assign: assign}),
    do: assign_remove(tag, %{assign: assign, remove: []})

  def assign_remove(tag = %Stories.Tag{}, %{remove: remove}),
    do: assign_remove(tag, %{assign: [], remove: remove})
end
