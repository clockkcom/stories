defmodule Stories.Attribute do
  use Stories.Resource, only: [:get, :list, :create, :delete]

  defstruct [
    :id,
    :name,
    :slug,
    :data_type
  ]

  def resource, do: "attributes"
end
