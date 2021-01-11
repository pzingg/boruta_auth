defmodule Boruta.Oauth.Client do
  @moduledoc """
  OAuth client schema
  """

  defstruct id: nil,
            secret: nil,
            authorize_scope: nil,
            authorized_scopes: [],
            redirect_uris: [],
            supported_grant_types: [],
            access_token_ttl: nil,
            authorization_code_ttl: nil,
            pkce: nil

  @type t :: %__MODULE__{
          id: any(),
          secret: String.t(),
          authorize_scope: boolean(),
          authorized_scopes: list(Boruta.Oauth.Scope.t()),
          redirect_uris: list(String.t()),
          supported_grant_types: list(String.t()),
          access_token_ttl: integer(),
          authorization_code_ttl: integer(),
          pkce: boolean()
        }
end
