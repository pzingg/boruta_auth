defmodule Boruta.Oauth.ApplicationMock do
  @moduledoc false
  @behaviour Boruta.Oauth.Application

  @impl Boruta.Oauth.Application
  def token_error(_conn, error), do: {:token_error, error}

  @impl Boruta.Oauth.Application
  def token_success(_conn, token), do: {:token_success, token}

  @impl Boruta.Oauth.Application
  def authorize_error(_conn, error), do: {:authorize_error, error}

  @impl Boruta.Oauth.Application
  def authorize_success(_conn, authorize), do: {:authorize_success, authorize}

  @impl Boruta.Oauth.Application
  def introspect_error(_conn, error), do: {:introspect_error, error}

  @impl Boruta.Oauth.Application
  def introspect_success(_conn, authorize), do: {:introspect_success, authorize}
end
