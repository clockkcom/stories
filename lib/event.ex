defmodule Stories.Event do
  use Stories.Resource, only: [:create]

  defstruct [
    :created_at,
    :created_at_locale,
    :data,
    :event_name,
    :extra,
    :id,
    :is_full,
    :is_grouped,
    :name,
    :next_event_id,
    :flag_id,
    :provider_id,
    :records,
    :user,
    :user_id
  ]

  defp resource, do: "events"
end
