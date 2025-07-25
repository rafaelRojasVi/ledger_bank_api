defmodule LedgerBankApi.Banking.Schemas.UserPayment do
  @moduledoc """
  Ecto schema for user payments. Represents a payment or transfer initiated by a user.
  """
  use Ecto.Schema
  import Ecto.Changeset
  import LedgerBankApi.CrudHelpers

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_payments" do
    field :amount, :decimal
    field :direction, :string # "CREDIT" or "DEBIT"
    field :description, :string
    field :payment_type, :string
    field :status, :string, default: "PENDING"
    field :posted_at, :utc_datetime
    field :external_transaction_id, :string

    belongs_to :user_bank_account, LedgerBankApi.Banking.Schemas.UserBankAccount

    timestamps(type: :utc_datetime)
  end

  @fields [
    :user_bank_account_id, :amount, :direction, :description, :payment_type, :status, :posted_at, :external_transaction_id
  ]
  @required_fields [
    :user_bank_account_id, :amount, :direction, :payment_type
  ]

  default_changeset(:base_changeset, @fields, @required_fields)

  def changeset(user_payment, attrs) do
    user_payment
    |> base_changeset(attrs)
    |> validate_direction()
    |> validate_amount_positive()
    |> validate_payment_type()
    |> validate_status()
    |> foreign_key_constraint(:user_bank_account_id)
  end

  defp validate_direction(changeset) do
    validate_inclusion(changeset, :direction, ["CREDIT", "DEBIT"])
  end

  defp validate_amount_positive(changeset) do
    case get_field(changeset, :amount) do
      nil -> changeset
      amount ->
        if Decimal.lt?(amount, Decimal.new(0)) do
          add_error(changeset, :amount, "must be positive")
        else
          changeset
        end
    end
  end

  defp validate_payment_type(changeset) do
    changeset
    |> validate_inclusion(:payment_type, ["TRANSFER", "PAYMENT", "DEPOSIT", "WITHDRAWAL"],
      message: "must be TRANSFER, PAYMENT, DEPOSIT, or WITHDRAWAL")
  end

  defp validate_status(changeset) do
    changeset
    |> validate_inclusion(:status, ["PENDING", "COMPLETED", "FAILED", "CANCELLED"],
      message: "must be PENDING, COMPLETED, FAILED, or CANCELLED")
  end
end
