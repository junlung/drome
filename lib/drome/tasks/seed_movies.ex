defmodule Drome.Tasks.SeedMovies do
  require Logger
  alias Drome.Tasks.FileUtils
  alias Drome.TMDBClient
  alias Drome.Schemas.Movie
  import Ecto.Query

  @base_url "http://files.tmdb.org/p/exports/movie_ids_"

  def run do
    url = download_url()
    path = "tmp/movie_ids.json.gz"
    FileUtils.create_directory(path)
    FileUtils.download_file(url, path)
    stream_file(path)
  end

  def download_url do
    date = Date.utc_today()
    date_string = Calendar.strftime(date, "%m_%d_%Y")
    "#{@base_url}#{date_string}.json.gz"
  end

  def stream_file(path) do
    IO.puts("Streaming file from #{path}")
    File.stream!(path, [:compressed])
    |> Stream.chunk_every(100)
    |> Task.async_stream(&process_chunk/1, max_concurrency: 10, timeout: :infinity)
    |> Enum.count()
  end

  defp process_chunk(chunk) do
    ids = chunk
      |> Enum.map(&Jason.decode!/1)
      |> Enum.map(&Map.get(&1, "id"))

    existing_ids = Drome.Repo.all(from m in Movie, where: m.tmdb_id in ^ids, select: m.tmdb_id)
    new_ids = ids -- existing_ids

    movies = new_ids
      |> Task.async_stream(fn id ->
        case TMDBClient.get_movie(id) do
          {:ok, response} when response.status_code == 429 ->
            {:ok, nil}
          {:ok, tmdb_movie} -> Movie.struct_from_tmdb(tmdb_movie)
          {:error, reason} ->
            Logger.info("Failed to fetch movie with id #{id}: #{reason}")
            {:ok, nil}
        end
      end, max_concurrency: 10)
      |> Enum.map(fn {:ok, movie} -> movie end)
    Logger.info("Inserting #{length(movies)} movies")
    Drome.Movies.insert_movie_batch(movies)
  end
end
