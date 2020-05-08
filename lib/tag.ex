defmodule Stories.Tag do
  use Stories.Resource

  defstruct [
    :id,
    :name,
    :slug
  ]

  def resource, do: "tags"
end
