defmodule Boruta.Oauth.Authorization.Code do
  @moduledoc """
  Code authorization
  """

  import Boruta.Config, only: [codes: 0]

  alias Boruta.Oauth.Client
  alias Boruta.Oauth.Error
  alias Boruta.Oauth.Token

  @doc """
  Authorize the code corresponding to the given params.

  ## Examples
      iex> authorize(value: "value", redirect_uri: "redirect_uri")
      {:ok, %Boruta.Oauth.Token{...}}
  """
  @spec authorize(%{
          value: String.t(),
          redirect_uri: String.t(),
          client: Client.t(),
          code_verifier: String.t()
        }) ::
          {:error,
           %Error{
             :error => :invalid_code,
             :error_description => String.t(),
             :format => nil,
             :redirect_uri => nil,
             :status => :bad_request
           }}
          | {:ok, %Token{}}
  def authorize(%{value: value, redirect_uri: redirect_uri, client: %Client{pkce: false}}) do
    with %Token{} = token <- codes().get_by(value: value, redirect_uri: redirect_uri),
         :ok <- Token.expired?(token) do
      {:ok, token}
    else
      {:error, error} ->
        {:error, %Error{status: :bad_request, error: :invalid_code, error_description: error}}

      nil ->
        {:error,
         %Error{
           status: :bad_request,
           error: :invalid_code,
           error_description: "Provided authorization code is incorrect."
         }}
    end
  end

  def authorize(%{
        value: value,
        redirect_uri: redirect_uri,
        client: %Client{pkce: true},
        code_verifier: code_verifier
      }) do
    with %Token{} = token <- codes().get_by(value: value, redirect_uri: redirect_uri),
         :ok <- check_code_challenge(token, code_verifier),
         :ok <- Token.expired?(token) do
      {:ok, token}
    else
      {:error, :invalid_code_verifier} ->
        {:error, %Error{status: :bad_request, error: :invalid_request, error_description: "Code verifier is invalid."}}
      {:error, error} ->
        {:error, %Error{status: :bad_request, error: :invalid_code, error_description: error}}

      nil ->
        {:error,
         %Error{
           status: :bad_request,
           error: :invalid_code,
           error_description: "Provided authorization code is incorrect."
         }}
    end
  end

  defp check_code_challenge(%Token{
         code_challenge_hash: code_challenge_hash,
         code_challenge_method: "plain"
  }, code_verifier) do
    case Token.hash(code_verifier) == code_challenge_hash do
      true -> :ok
      false -> {:error, :invalid_code_verifier}
    end
  end

  # TODO integration test
  defp check_code_challenge(%Token{
         code_challenge_hash: code_challenge_hash,
         code_challenge_method: "S256"
  }, code_verifier) do
    case :crypto.hash(:sha256, code_verifier) |> Base.url_encode64 |> Token.hash == code_challenge_hash do
      true -> :ok
      false -> {:error, :invalid_code_verifier}
    end
  end
end
