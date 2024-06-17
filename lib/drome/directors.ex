defmodule Drome.Directors do
  alias Drome.Repo
  alias Drome.Schemas.Director

  def find_by_tmdb_id(tmdb_id) do
    Repo.get_by(Director, tmdb_id: tmdb_id)
  end

  def insert_director(attrs) do
    %Director{}
    |> Director.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
    |> case do
      {:ok, director} -> {:ok, director}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def insert_tmdb_director(tmdb_id) do
    case Drome.TMDBClient.get_person(tmdb_id) do
      {:ok, tmdb_director} ->
        %Director{}
        |> Director.changeset_from_tmdb(tmdb_director)
        |> Repo.insert(on_conflict: :nothing)
        |> case do
          {:ok, director} -> {:ok, director}
          {:error, changeset} -> {:error, changeset}
        end
      {:error, reason} -> {:error, reason}
    end
  end

  def find_or_insert_director(tmdb_id) do
    case find_by_tmdb_id(tmdb_id) do
      nil -> insert_tmdb_director(tmdb_id)
      director -> {:ok, director}
    end
  end
end
