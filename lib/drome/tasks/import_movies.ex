defmodule Drome.Tasks.ImportMovies do
  require Logger

  @batch_size 100

  def process_file(path) do
    path
    |> File.stream!()
    |> Stream.map(fn line ->
      case Jason.decode(line) do
        {:ok, data} -> data
        {:error, reason} -> Logger.error("Error decoding JSON: #{inspect(reason)}")
      end
    end)
    |> Stream.map(&Map.get(&1, "id"))
    |> Stream.chunk_every(@batch_size)
    |> Enum.each(fn ids ->
      Process.sleep(3000)
      async_process_movies(ids)
    end)
  end

  def sync_directors do
    Enum.each(Drome.Repo.all(Drome.Schemas.Movie), fn movie ->
      Process.sleep(1000)
      async_process_directors(movie)
    end)
  end

  defp async_process_directors(movie) do
    Task.async(fn ->
      :poolboy.transaction(:worker, fn pid ->
        try do
          GenServer.call(pid, {:process_directors, movie}, 60000)
        catch
          _ ->
            :poolboy.checkin(:worker, pid)
            {:error, "Error processing directors"}
        end
      end, 60000)
    end)
  end

  defp async_process_movies(tmdb_ids) do
    Task.async(fn ->
      :poolboy.transaction(:worker, fn pid ->
        try do
          GenServer.call(pid, {:process_movies, tmdb_ids}, 60000)
        catch
          _ ->
            :poolboy.checkin(:worker, pid)
            {:error, "Error processing movies"}
        end
      end, 60000)
    end)
  end
end
