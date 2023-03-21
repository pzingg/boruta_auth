defmodule Boruta.Migrations.AddClientUserId do
  use Ecto.Migration

  def change do
    alter table(:oauth_clients) do
      add(:user_id, :string, null: false, default: "ANONYMOUS")
    end

    create unique_index(:oauth_clients, [:user_id, :name])
  end
end
