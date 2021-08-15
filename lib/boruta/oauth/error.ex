defmodule Boruta.Oauth.Error do
  @moduledoc """
  Boruta OAuth errors

  Intended to follow [OAuth 2.0 errors](https://tools.ietf.org/html/rfc6749#section-5.2). Additionnal errors are provided as purpose.
  """

  alias Boruta.Oauth.CodeRequest
  alias Boruta.Oauth.Error
  alias Boruta.Oauth.HybridRequest
  alias Boruta.Oauth.TokenRequest

  @type t :: %__MODULE__{
          status: :internal_server_error | :bad_request | :unauthorized,
          error:
            :invalid_request
            | :invalid_client
            | :invalid_scope
            | :invalid_code
            | :invalid_resource_owner
            | :unknown_error,
          error_description: String.t(),
          format: :query | :fragment | nil,
          redirect_uri: String.t() | nil,
          state: String.t() | nil
        }
  defstruct status: nil,
            error: :error,
            error_description: "",
            format: nil,
            redirect_uri: nil,
            state: nil

  @spec with_format(
          error :: Error.t(),
          request :: CodeRequest.t() | TokenRequest.t() | HybridRequest.t()
        ) :: Error.t()
  def with_format(%Error{} = error, %CodeRequest{redirect_uri: redirect_uri}) do
    %{error | format: :query, redirect_uri: redirect_uri}
  end

  def with_format(%Error{} = error, %HybridRequest{state: state}) do
    %{error | state: state}
  end

  def with_format(%Error{} = error, %TokenRequest{redirect_uri: redirect_uri, state: state}) do
    %{error | format: :fragment, redirect_uri: redirect_uri, state: state}
  end

  def with_format(error, _), do: error

  @spec redirect_to_url(error :: t()) :: url :: String.t()
  def redirect_to_url(%__MODULE__{format: nil}), do: ""

  def redirect_to_url(%__MODULE__{} = error) do
    query_params = query_params(error)

    url(error, query_params)
  end

  defp query_params(%__MODULE__{
         error: error,
         error_description: error_description,
         state: state
       }) do
    %{error: error, error_description: error_description, state: state}
    |> Enum.filter(fn
      {_key, nil} -> false
      _ -> true
    end)
    |> URI.encode_query()
  end

  defp url(%Error{redirect_uri: redirect_uri, format: :query}, query_params),
    do: "#{redirect_uri}?#{query_params}"

  defp url(%Error{redirect_uri: redirect_uri, format: :fragment}, query_params),
    do: "#{redirect_uri}##{query_params}"
end
