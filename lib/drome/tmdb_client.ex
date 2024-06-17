defmodule Drome.TMDBClient do
  @api_url "https://api.themoviedb.org/3"
  @api_key Application.compile_env(:drome,:TMDB_API_KEY, nil)

  # Fetch a movie from the TMDB API
  def get_movie(tmdb_id) do
    url = "#{@api_url}/movie/#{tmdb_id}?api_key=#{@api_key}"
    case get_resource(url) do
      {:ok, movie_data} ->
        {:ok, movie_data}
      {:error, reason} ->
        IO.puts("Error fetching movie: #{reason}")
        {:error, reason}
    end
  end

  # Fetch a person from the TMDB API
  def get_person(tmdb_id) do
    url = "#{@api_url}/person/#{tmdb_id}?api_key=#{@api_key}"
    case get_resource(url) do
      {:ok, director_data} ->
        {:ok, director_data}
      {:error, reason} ->
        {:error, reason}
    end
  end

  # Fetch a movie's credits from the TMDB API
  def get_movie_credits(tmdb_id) do
    url = "#{@api_url}/movie/#{tmdb_id}/credits?api_key=#{@api_key}"
    case get_resource(url) do
      {:ok, credits_data} ->
        {:ok, credits_data}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def get_movie_url(tmdb_id) do
    "#{@api_url}/movie/#{tmdb_id}?api_key=#{@api_key}"
  end

  def get_movie_director_ids(tmdb_id) do
    response = get_movie_credits(tmdb_id)
    case response do
      {:ok, credits_data} ->
        director_ids =
          credits_data["crew"]
          |> Enum.filter(fn person -> person["job"] == "Director" end)
          |> Enum.map(fn person -> person["id"] end)
        {:ok, director_ids}
      {:error, reason} ->
        {:error, reason}
    end
  end

  # Send a request to the TMDB API
  def get_resource(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            {:ok, data}
          _ ->
            {:error, "couldn't parse JSON response"}
        end
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Resource not found"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def sanitized_movie(tmdb_movie) do
    %{
      title: tmdb_movie["title"],
      tagline: tmdb_movie["tagline"],
      overview: tmdb_movie["overview"],
      runtime: tmdb_movie["runtime"],
      original_language: tmdb_movie["original_language"],
      original_title: tmdb_movie["original_title"],
      budget: tmdb_movie["budget"],
      revenue: tmdb_movie["revenue"],
      release_date: convert_date(tmdb_movie["release_date"]),
      year: extract_year(tmdb_movie["release_date"]),
      poster_path: tmdb_movie["poster_path"],
      backdrop_path: tmdb_movie["backdrop_path"],
      tmdb_id: tmdb_movie["id"],
      tmdb_popularity: tmdb_movie["popularity"],
      tmdb_vote_average: tmdb_movie["vote_average"],
      tmdb_vote_count: tmdb_movie["vote_count"]
    }
  end

  defp convert_date(date) do
    case Date.from_iso8601(date) do
      {:ok, date} -> date
      {:error, _} -> nil
    end
  end

  defp extract_year(date) do
    case Date.from_iso8601(date) do
      {:ok, date} -> date.year
      {:error, _} -> nil
    end
  end
end
