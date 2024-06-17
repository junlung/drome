defmodule Drome.Movies do
  alias Drome.Repo
  alias Drome.Schemas.Movie
  alias Drome.Schemas.MovieDirector
  import Ecto.Query

  def find_by_tmdb_id(tmdb_id) do
    Repo.get_by(Movie, tmdb_id: tmdb_id)
  end

  def insert_movie(attrs) do
    %Movie{}
    |> Movie.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
    |> case do
      {:ok, movie} -> {:ok, movie}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def insert_tmdb_movie(tmdb_id) do
    case Drome.TMDBClient.get_movie(tmdb_id) do
      {:ok, tmdb_movie} ->
        %Movie{}
        |> Movie.changeset_from_tmdb(tmdb_movie)
        |> Repo.insert(on_conflict: :nothing)
        |> case do
          {:ok, movie} -> {:ok, movie}
          {:error, changeset} -> {:error, changeset}
        end
      {:error, reason} -> {:error, reason}
    end
  end

  def insert_movie_batch(movies) do
    Repo.insert_all(Movie, movies, on_conflict: :nothing)
  end

  def find_or_insert_movie(tmdb_id) do
    case find_by_tmdb_id(tmdb_id) do
      nil -> {:ok, insert_tmdb_movie(tmdb_id)}
      movie -> {:ok, movie}
    end
  end

  def insert_directors(movie) do
    case Drome.TMDBClient.get_movie_director_ids(movie.tmdb_id) do
      {:ok, director_ids} ->
        Enum.each(director_ids, fn director_id ->
          case Drome.Directors.find_or_insert_director(director_id) do
            {:ok, director} ->
              Repo.insert(%MovieDirector{movie_id: movie.id, director_id: director.id})
            {:error, _} -> {:error, "Error inserting director"}
          end
        end)
        {:ok, "Directors inserted"}
      {:error, reason} -> {:error, reason}
    end
  end

  def get_existing_tmdb_ids(tmdb_ids) do
    Repo.all(from m in Movie, where: m.tmdb_id in ^tmdb_ids, select: m.tmdb_id)
  end

  def list_movies(params \\ %{}) do
    Movie
    |> preload(:directors)
    |> Repo.paginate(params)
  end
end
