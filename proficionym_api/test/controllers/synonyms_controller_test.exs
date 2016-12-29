defmodule ProficionymApi.SynonymsControllerTest do
  use ProficionymApi.ConnCase

  alias ProficionymApi.Synonyms
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, synonyms_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    synonyms = Repo.insert! %Synonyms{}
    conn = get conn, synonyms_path(conn, :show, synonyms)
    assert json_response(conn, 200)["data"] == %{"id" => synonyms.id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, synonyms_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, synonyms_path(conn, :create), synonyms: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Synonyms, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, synonyms_path(conn, :create), synonyms: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    synonyms = Repo.insert! %Synonyms{}
    conn = put conn, synonyms_path(conn, :update, synonyms), synonyms: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Synonyms, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    synonyms = Repo.insert! %Synonyms{}
    conn = put conn, synonyms_path(conn, :update, synonyms), synonyms: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    synonyms = Repo.insert! %Synonyms{}
    conn = delete conn, synonyms_path(conn, :delete, synonyms)
    assert response(conn, 204)
    refute Repo.get(Synonyms, synonyms.id)
  end
end
