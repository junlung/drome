defmodule Drome.Tasks.MovieProcessor do
  use GenServer
  alias Drome.Movies
  alias Drome.TMDBClient

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:process_movies, ids}, _from, _state) do
    {:ok, message} = process_movies(ids)
    {:reply, message, nil}
  end

  def handle_call({:process_directors, movie}, _from, _state) do
    {:ok, message} = insert_directors(movie)
    {:reply, message, nil}
  end

  defp insert_directors(movie) do
    case Movies.insert_directors(movie) do
      {:ok, _} -> {:ok, "Directors inserted"}
      {:error, _} -> {:ok, "No directors found"}
    end
  end

  def process_movies(tmdb_ids) do
    case fetch_movies(tmdb_ids) do
      [] ->
        IO.puts("No movies found")
        {:ok, "No movies found"}
      movies ->
        timestamped_movies =
          movies
          |> Enum.map(fn movie ->
            movie
            |> Map.put(:inserted_at, DateTime.utc_now() |> DateTime.truncate(:second))
            |> Map.put(:updated_at, DateTime.utc_now() |> DateTime.truncate(:second))
          end)
        Movies.insert_movie_batch(timestamped_movies)
        IO.puts("Inserted #{length(movies)} movies")
        {:ok, "Inserted #{length(movies)} movies"}
    end
  end

  defp fetch_movies(tmdb_ids) do
    # remove values that already exist in the database
    existing_tmdb_ids = Movies.get_existing_tmdb_ids(tmdb_ids)
    tmdb_ids = tmdb_ids -- existing_tmdb_ids

    IO.puts("Fetching #{length(tmdb_ids)} movies")
    tmdb_ids
    |> Task.async_stream(&process_movie/1, max_concurrency: 3)
    |> Enum.map(fn
      {:ok, {:ok, movie}} -> movie
      {:ok, movie} -> movie
      {:error, _} -> nil
    end)
  end

  defp process_movie(tmdb_id) do
    case TMDBClient.get_movie(tmdb_id) do
      {:ok, movie_data} ->
        {:ok, TMDBClient.sanitized_movie(movie_data)}
      {:error, reason} ->
        {:error, {tmdb_id, reason}}
    end
  end
end
