defmodule Stories do
  @moduledoc """
  # Stories

  An Elixir API wrapper for the Stories API (https://www.getstories.io/)

  Stories gathers everything that happens regarding a user on a timeline,
  so you can understand what is going on and take action in the right direction.

  ## Installation

  Add `stories` to your list of dependencies in `mix.exs`:
  ```
  def deps do
  [
    {:stories, "~> 0.1.0"}
  ]
  end
  ```

  Add your Stories API key to your `config.ex`

  ```
  import Config

  config :stories,
     acccess_token: "asdfqwer1234"
  ```

  ## Basic Usage

  Get list of users:

      iex> users = Stories.User.list()
      iex> [%Stories.User{} | _] = users

  Create an event:

      iex> event = Stories.Event.create(%{
      ...>    user_id: "f3111ed7-9372-453e-8838-19ab2de8adc0",
      ...>    name: "A developer tested the Elixir Stories API wrapper",
      ...>    data: %{}
      ...>  })
      iex> %Stories.Event{} = event
  """
end
