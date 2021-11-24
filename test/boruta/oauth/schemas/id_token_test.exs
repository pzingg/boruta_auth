defmodule Boruta.Oauth.IdTokenTest do
  use ExUnit.Case
  import Mox

  alias Boruta.Oauth.Client
  alias Boruta.Oauth.IdToken
  alias Boruta.Oauth.ResourceOwner
  alias Boruta.Oauth.Token

  setup :verify_on_exit!

  setup do
    claims = %{"resource_owner_claim" => "claim"}
    expect(Boruta.Support.ResourceOwners, :claims, fn (_sub, _scope) -> claims end)
    {:ok, claims: claims}
  end

  test "generates an id token with a code" do
    client = build_client()
    inserted_at = DateTime.utc_now()
    last_login_at = DateTime.utc_now()
    code = %Token{
      type: "code",
      sub: "sub",
      client: client,
      value: "value",
      inserted_at: inserted_at,
      resource_owner: %ResourceOwner{sub: "sub", last_login_at: last_login_at},
      scope: "scope",
    }
    nonce = "nonce"

    assert %{
      sub: "sub",
      client: ^client,
      inserted_at: ^inserted_at,
      scope: "scope",
      value: value,
      type: "id_token"
    } = IdToken.generate(%{code: code}, nonce)

    signer = Joken.Signer.create("RS512", %{"pem" => client.private_key, "aud" => client.id})

    {:ok, claims} = IdToken.Token.verify_and_validate(value, signer)
    client_id = client.id
    auth_time = DateTime.to_unix(last_login_at)

    assert %{
      "aud" => ^client_id,
      "iat" => _iat,
      "exp" => _exp,
      "sub" => "sub",
      "nonce" => ^nonce,
      "c_hash" => _c_hash,
      "auth_time" => ^auth_time,
      "resource_owner_claim" => "claim"
    } = claims
  end

  test "generates an id token with a token" do
    client = build_client()
    inserted_at = DateTime.utc_now()
    last_login_at = DateTime.utc_now()
    token = %Token{
      type: "access_token",
      sub: "sub",
      client: client,
      value: "value",
      inserted_at: inserted_at,
      resource_owner: %ResourceOwner{sub: "sub", last_login_at: last_login_at},
      scope: "scope"
    }
    nonce = "nonce"

    assert %{
      sub: "sub",
      client: ^client,
      inserted_at: ^inserted_at,
      scope: "scope",
      value: value,
      type: "id_token"
    } = IdToken.generate(%{token: token}, nonce)

    signer = Joken.Signer.create("RS512", %{"pem" => client.private_key, "aud" => client.id})

    {:ok, claims} = IdToken.Token.verify_and_validate(value, signer)
    client_id = client.id
    auth_time = DateTime.to_unix(last_login_at)

    assert %{
      "aud" => ^client_id,
      "iat" => _iat,
      "exp" => _exp,
      "sub" => "sub",
      "nonce" => ^nonce,
      "at_hash" => _at_hash,
      "auth_time" => ^auth_time,
      "resource_owner_claim" => "claim"
    } = claims
  end

  test "generates an id token with a token and a code" do
    client = build_client()
    inserted_at = DateTime.utc_now()
    last_login_at = DateTime.utc_now()
    code = %Token{
      type: "code",
      sub: "sub",
      client: client,
      value: "code",
      inserted_at: inserted_at,
      resource_owner: %ResourceOwner{sub: "sub", last_login_at: last_login_at},
      scope: "scope"
    }
    token = %Token{
      type: "access_token",
      sub: "sub",
      client: client,
      value: "token",
      inserted_at: inserted_at,
      resource_owner: %ResourceOwner{sub: "sub", last_login_at: last_login_at},
      scope: "scope"
    }
    nonce = "nonce"

    assert %{
      sub: "sub",
      client: ^client,
      inserted_at: ^inserted_at,
      scope: "scope",
      value: value,
      type: "id_token"
    } = IdToken.generate(%{token: token, code: code}, nonce)

    signer = Joken.Signer.create("RS512", %{"pem" => client.private_key, "aud" => client.id})

    {:ok, claims} = IdToken.Token.verify_and_validate(value, signer)
    client_id = client.id
    auth_time = DateTime.to_unix(last_login_at)

    assert %{
      "aud" => ^client_id,
      "iat" => _iat,
      "exp" => _exp,
      "sub" => "sub",
      "nonce" => ^nonce,
      "at_hash" => _at_hash,
      "c_hash" => _c_hash,
      "auth_time" => ^auth_time,
      "resource_owner_claim" => "claim"
    } = claims
  end

  test "generates an id token with a base token" do
    client = build_client()
    inserted_at = DateTime.utc_now()
    base_token = %Token{
      type: "base_token",
      sub: "sub",
      resource_owner: %ResourceOwner{sub: "sub"},
      client: client,
      value: "token",
      inserted_at: inserted_at,
      scope: "scope"
    }
    nonce = "nonce"

    assert %{
      sub: "sub",
      client: ^client,
      inserted_at: ^inserted_at,
      scope: "scope",
      value: value,
      type: "id_token"
    } = IdToken.generate(%{base_token: base_token}, nonce)

    signer = Joken.Signer.create("RS512", %{"pem" => client.private_key, "aud" => client.id})

    {:ok, claims} = IdToken.Token.verify_and_validate(value, signer)
    client_id = client.id

    assert %{
      "aud" => ^client_id,
      "iat" => _iat,
      "exp" => _exp,
      "sub" => "sub",
      "nonce" => ^nonce,
      "auth_time" => _auth_time,
      "resource_owner_claim" => "claim"
    } = claims
  end

  def build_client do
    %Client{
      id: "client_id",
      id_token_ttl: 10,
      private_key:
        "-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEA1PaP/gbXix5itjRCaegvI/B3aFOeoxlwPPLvfLHGA4QfDmVO\nf8cU8OuZFAYzLArW3PnnwWWy39nVJOx42QRVGCGdUCmV7shDHRsr86+2DlL7pwUa\n9QyHsTj84fAJn2Fv9h9mqrIvUzAtEYRlGFvjVTGCwzEullpsB0GJafopUTFby8Wd\nSq3dGLJBB1r+Q8QtZnAxxvolhwOmYkBkkidefmm48X7hFXL2cSJm2G7wQyinOey/\nU8xDZ68mgTakiqS2RtjnFD0dnpBl5CYTe4s6oZKEyFiFNiW4KkR1GVjsKwY9oC2t\npyQ0AEUMvk9T9VdIltSIiAvOKlwFzL49cgwZDwIDAQABAoIBAG0dg/upL8k1IWiv\n8BNphrXIYLYQmiiBQTPJWZGvWIC2sl7i40yvCXjDjiRnZNK9HwgL94XtALCXYRFR\nJD41bRA3MO5A0HSPIWwJXwS10/cU56HVCNHjwKa6Rz/QiG2kNASMZEMzlvHtrjna\ndx36/sjI3HH8gh1BaTZyiuDE72SMkPbL838jfL1YY9uJ0u6hWFDbdn3sqPfJ6Cnz\n1cu0piT35nkilnIGCNYA0i3lyMeo4XrdXaAJdN9nnqbCi5ewQWqaHbrIIY5LTgzJ\nYlOr3IiecyokFxHCbULXle60u0KqXYgBHmlQJJr1Dj4c9AkQmefjC2jRMlhOrIzo\nIkIUeMECgYEA+MNLB+w6vv1ogqzM3M1OLt6bziWJCn+XkziuMrCiY9KeDD+S70+E\nhfbhM5RjCE3wxC/k59039laT973BmdMHxrDd2zSjOFmCIORv5yrD5oBHMaMZcwuQ\n45Xisi4aoQoOhyznSnjo/RjeQB7qEDzXFznLLNT79HzqyAtCWD3UIu8CgYEA2yik\n9FKl7HJEY94D2K6vNh1AHGnkwIQC72pXzlUrVuwQYngj6/Gkhw8ayFBApHfwVCXj\no9rDYPdNrrAs0Zz0JsiJp6bOCEKCrMYE16UiejUUAg/OZ5eg6+3m3/iWatkzLUuK\n1LIkVBJlEyY0uPuAaBF0V0VleNvfCGhVYOn46+ECgYAUD4OsduNh5YOZDiBTKgdF\nBlSgMiyz+QgbKjX6Bn6B+EkgibvqqonwV7FffHbkA40H9SjLfe52YhL6poXHRtpY\nroillcAX2jgBOQrBJJS5sNyM5y81NNiRUdP/NHKXS/1R71ATlF6NkoTRvOx5NL7P\ns6xryB0tYSl5ylamUQ4bZwKBgHF6FB9mA//wErVbKcayfIqajq2nrwh30kVBXQG7\nW9uAE+PIrWDoF/bOvWFnHHGMoOYRUFNxXKUCqDiBhFNs34aNY6lpV1kzhxIK3ksC\neF2qyhdfM9Kz0mEXJ+pkfw4INNWJPfNv4hueArPtnnMB1rUMBJ+DkU0JG+zwiPTL\ncVZBAoGBAM6kOsh5KGn3aI83g9ZO0TrKLXXFotxJt31Wu11ydj9K33/Qj3UXcxd4\nJPXr600F0DkLeUKBob6BALeHFWcrSz5FGLGRqdRxdv+L6g18WH5m2xEs7o6M6e5I\nIhyUC60ZewJ2M8rV4KgCJJdZE2kENlSgjU92IDVPT9Oetrc7hQJd\n-----END RSA PRIVATE KEY-----\n\n",
    }
  end
end