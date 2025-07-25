defmodule LedgerBankApi.Helpers.AuthorizationHelpersTest do
  use ExUnit.Case, async: true
  import LedgerBankApi.Helpers.AuthorizationHelpers
  alias LedgerBankApi.Users.User

  test "require_role! allows correct role" do
    user = %User{role: "admin"}
    assert :ok == (try do
      require_role!(user, "admin")
      :ok
    rescue
      _ -> :error
    end)
  end

  test "require_role! raises for wrong role" do
    user = %User{role: "user"}
    assert_raise RuntimeError, fn ->
      require_role!(user, "admin")
    end
  end

  test "require_role! allows user role for user actions" do
    user = %User{role: "user"}
    assert :ok == (try do
      require_role!(user, "user")
      :ok
    rescue
      _ -> :error
    end)
  end

  test "require_role! allows support role for support actions" do
    user = %User{role: "support"}
    assert :ok == (try do
      require_role!(user, "support")
      :ok
    rescue
      _ -> :error
    end)
  end

  test "require_role! blocks privilege escalation (user as admin)" do
    user = %User{role: "user"}
    assert_raise RuntimeError, ~r/Insufficient permissions/, fn ->
      require_role!(user, "admin")
    end
  end

  test "require_role! blocks privilege escalation (support as admin)" do
    user = %User{role: "support"}
    assert_raise RuntimeError, ~r/Insufficient permissions/, fn ->
      require_role!(user, "admin")
    end
  end

  test "require_role! raises for missing user struct" do
    assert_raise RuntimeError, ~r/Insufficient permissions/, fn ->
      require_role!(nil, "admin")
    end
  end

  test "require_role! blocks when role is missing in user struct" do
    user = %User{}
    assert_raise RuntimeError, ~r/Insufficient permissions/, fn ->
      require_role!(user, "admin")
    end
  end

  test "require_role! allows admin for any role" do
    user = %User{role: "admin"}
    for role <- ["admin", "user", "support"] do
      assert :ok == (try do
        require_role!(user, role)
        :ok
      rescue
        _ -> :error
      end)
    end
  end
end
