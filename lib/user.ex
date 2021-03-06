defmodule Stories.User do
  use Stories.Resource

  defstruct [
    :id,
    :user_id,
    :name,
    :email,
    :phone,
    :created_at,
    :updated_at,
    :is_full,
    :attributes,
    tags: []
  ]

  defp resource, do: "users"
end
