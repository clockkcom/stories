defmodule Stories.Attribute do
  use Stories.Resource, only: [:get, :list, :create, :delete]

  defstruct [
    :id,
    :name,
    :slug,
    :data_type
  ]

  defp resource, do: "attributes"
end
