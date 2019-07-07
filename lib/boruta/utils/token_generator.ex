defmodule Boruta.TokenGenerator do
  @moduledoc false

  @behaviour Boruta.Oauth.TokenGenerator

  use Puid, bits: 256, charset: :alphanum

  @impl Boruta.Oauth.TokenGenerator
  def generate(_, %Boruta.Oauth.Token{}) do
    generate()
  end

  @impl Boruta.Oauth.TokenGenerator
  def secret(%Boruta.Oauth.Client{}) do
    generate()
  end
end
