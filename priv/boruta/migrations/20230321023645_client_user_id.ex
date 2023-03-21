defmodule Boruta.Migrations.ClientUserId do
  @moduledoc false

  defmacro __using__(_args) do
    quote do
      def change do

        # 20230321023645_client_user_id.exs
        alter table(:oauth_clients) do
          add(:user_id, :string, null: false, default: "ANONYMOUS")
        end

        create unique_index(:oauth_clients, [:user_id, :name])
      end
    end
  end
end
