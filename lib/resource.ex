defmodule Stories.Resource do
  @moduledoc """
  All Stories requests require authorization headers. These can be set by deafult in your config file:

  ## Example Config
      config :stories,
        api_key: "your api key"

  The authorization headers can be customized for each request using the following options provided as a keyword list in each resource function:

  ## Shared Authorization Options
  * `:access_token` - Required. Accepts string. Can be set in config
  """

  def get_auth_headers() do
    case Application.fetch_env(:stories, :acccess_token) do
      :error ->
        raise(StoriesError, "Error: missing :access_token environment variable")

      {:ok, access_token} ->
        [{"Authorization", "Bearer #{access_token}"}]
    end
  end

  defmacro __using__(opts) do
    api_url =
      unless Keyword.get(opts, :api_url_override) do
        quote do
          defp api_url(options \\ []) do
            "https://api.getstories.io/v1"
          end
        end
      end

    pagination_data =
      unless Keyword.get(opts, :pagination_data_override) do
        quote do
          defp pagination_data(resource), do: resource
        end
      end

    resource_path =
      unless Keyword.get(opts, :resource_path_override) do
        quote do
          # Default to simply return the resource name as the resource path
          defp resource_path() do
            resource()
          end
        end
      end

    inject =
      case Keyword.get(opts, :only) do
        nil -> [:get, :list, :create, :update, :delete]
        list -> list
      end

    # list/1 requires get/1
    get =
      if :get in inject || :list in inject do
        quote do
          @doc """
          Retrieve #{__MODULE__} by id. Accepts a keyword list of options.

          returns %#{__MODULE__}{}

          ## Options
          * `:id` - The id of the resource you are trying to retrieve. Defaults to empty, giving same behaviour as list/1
          * `:get_parameters` - Map of query parameters that you want to include in the query.
          """
          def get(options \\ []) do
            resource_id = Keyword.get(options, :id)
            access_token = Keyword.get(options, :access_token)

            url =
              "#{api_url(options)}/#{resource_path()}"
              |> (fn url ->
                    # Avoid the trailing "/" character when not necessary
                    if resource_id do
                      "#{url}/#{resource_id}"
                    else
                      url
                    end
                  end).()
              |> (fn url ->
                    case Keyword.get(options, :get_parameters) do
                      nil ->
                        url

                      get_parameters ->
                        url <> "?" <> URI.encode_query(get_parameters)
                    end
                  end).()

            case HTTPoison.get(url, Stories.Resource.get_auth_headers()) do
              {:ok, %HTTPoison.Response{status_code: 404}} ->
                nil

              {:ok, response = %HTTPoison.Response{status_code: 200, body: resp_body}} ->
                resource = Jason.decode!(resp_body, keys: :atoms)

                if Map.has_key?(pagination_data(resource), :links) do
                  # This means the resource is a list of the resource, in an attribute named after the resource
                  resource_key = :data

                  if Application.get_env(:stories, :env, :prod) == :test do
                    # lets learn about new keys that stories adds to their data objects without crashing in prod
                    resource[resource_key]
                    |> Enum.map(&struct!(__MODULE__, &1))
                  else
                    resource[resource_key]
                    |> Enum.map(&struct(__MODULE__, &1))
                  end
                else
                  struct!(__MODULE__, resource)
                end

              {:error, %HTTPoison.Error{reason: reason}} ->
                raise(StoriesError, "Error: #{inspect(reason)}")
            end
          end
        end
      end

    list =
      if :list in inject do
        quote do
          defp get_recursive(
                 options \\ [],
                 collector \\ [],
                 page \\ 1,
                 per_page \\ 100
               ) do
            get_parameters =
              case Keyword.get(options, :get_parameters) do
                nil ->
                  %{page: page, per_page: per_page}

                get_parameters ->
                  Map.merge(get_parameters, %{page: page, per_page: per_page})
              end

            resources = get(options ++ [get_parameters: get_parameters])

            if Enum.count(resources) == per_page do
              get_recursive(
                options,
                resources ++ collector,
                page + 1,
                per_page
              )
            else
              # all pages exhausted for resource. return collection
              resources ++ collector
            end
          end

          @doc """
          Retrieve list of #{__MODULE__} Stories resource. Shares all options with get/1

          returns [%#{__MODULE__}{}]

          ## Options
          * `:page` - The page number to use in pagination. Default 1
          * `:per_page` - The number of records to return per page. Currently only 50 is supported.
          * `:recurse_pages` - Recursively follow each next page and return all records.
          * `:get_parameters` - Map of query parameters that you want to include in the query.
          """
          def list(options \\ []) do
            page = Keyword.get(options, :page, 1)
            per_page = Keyword.get(options, :per_page, 50)

            if Keyword.get(options, :recurse_pages) do
              get_recursive(options, [], page, per_page)
            else
              get(options ++ [get_parameters: %{page: page, per_page: per_page}])
            end
          end
        end
      end

    create =
      if :create in inject do
        quote do
          @doc """
          Create new #{__MODULE__} resource. Parameters are not validated, but passed along in the request body. Please see Stories API documentation for the appropriate body parameters for your resource.

          returns %#{__MODULE__}{}

          ## Params
          * `properties` - Map of resource properties to create the resource with. This will be different for each resource based on the specification in Stories API
          """
          def create(properties, options \\ []) do
            url = "#{api_url(options)}/#{resource_path()}"

            body =
              case Jason.encode(properties) do
                {:ok, body} ->
                  body

                {:error, %Jason.EncodeError{message: message}} ->
                  raise(
                    StoriesError,
                    "Invalid :properties. Was not able to encode to JSON. #{message}"
                  )
              end

            case HTTPoison.post(
                   url,
                   body,
                   Stories.Resource.get_auth_headers() ++ [{"Content-Type", "application/json"}]
                 ) do
              {:ok, %HTTPoison.Response{body: resp_body}} ->
                resource = Jason.decode!(resp_body, keys: :atoms)

                struct!(__MODULE__, resource)

              {:error, %HTTPoison.Response{status_code: 422, body: body}} ->
                {:error, Jason.decode!(body)}

              {:error, %HTTPoison.Error{reason: reason}} ->
                raise(StoriesError, "Error: #{inspect(reason)}")
            end
          end
        end
      end

    update =
      if :update in inject do
        quote do
          @doc """
          Update given #{__MODULE__} resource. Parameters are not validated, but passed along in the request body. Please see Stories API documentation for the appropriate body parameters for your resource.

          returns %#{__MODULE__}{}

          ## Params
          * `id` - id of `#{__MODULE__}` resource being updated.
          * `changes` - Map of changes to be applied to the resource.
          """
          def update(id, changes, options \\ []) do
            url = "#{api_url(options)}/#{resource_path()}/#{id}"

            body =
              case Jason.encode(changes) do
                {:ok, body} ->
                  body

                {:error, %Jason.EncodeError{message: message}} ->
                  raise(
                    StoriesError,
                    "Invalid :changes. Was not able to encode to JSON. #{message}"
                  )
              end

            case HTTPoison.post(
                   url,
                   body,
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
          end
        end
      end

    delete =
      if :delete in inject do
        quote do
          @doc """
          Delete Stories #{__MODULE__} with provided id.

          Will return `:ok` on success, `{:error, 404}` if resource not found, or throw `StoriesError` for implementation errors.

          ## Params
          * `id` - id of #{__MODULE__} resource to delete
          """
          def delete(id, options \\ []) do
            url = "#{api_url(options)}/#{resource_path()}/#{id}"

            case HTTPoison.delete(url, Stories.Resource.get_auth_headers()) do
              {:ok, resp} ->
                case resp.status_code do
                  204 ->
                    :ok

                  404 ->
                    {:error, 404}

                  status_code when status_code > 399 ->
                    error = Jason.decode!(resp.body, keys: :atoms)
                    raise(StoriesError, error)
                end

              {:error, %HTTPoison.Response{status_code: 422, body: body}} ->
                {:error, Jason.decode!(body)}

              {:error, %HTTPoison.Error{reason: reason}} ->
                raise(StoriesError, "Error: #{inspect(reason)}")
            end
          end
        end
      end

    [api_url, pagination_data, resource_path, get, list, create, update, delete]
  end
end
