defmodule Drome.Tasks.FileUtils do
  def create_directory(path) do
    case File.mkdir_p(Path.dirname(path)) do
      :ok -> IO.puts("Created directory: #{path}")
      {:error, reason} -> IO.puts("Failed to create directory: #{reason}")
    end
  end

  def cleanup_directory(path) do
    case File.rm_rf(path) do
      {:ok, _} -> IO.puts("Cleaned up directory: #{path}")
      {:error, reason, _} -> IO.puts("Failed to clean up directory: #{reason}")
    end
  end

  def download_file(url, path) do
    case HTTPoison.get(url, [], [follow_redirect: true, timeout: 60_000, recv_timeout: 60_000]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        File.write!(path, body)
        IO.puts("Downloaded file to: #{path}")
        {:ok, path}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Failed to download file. HTTP status code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to download file. Error: #{inspect(reason)}"}
    end
  end
end
