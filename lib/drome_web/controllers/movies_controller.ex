defmodule DromeWeb.MoviesController do
  use DromeWeb, :controller

  alias Drome.Repo
  alias Drome.Schemas.Movie
  alias Drome.Movies

  def index(conn, params) do
    movies = Movies.list_movies(params)

    json(conn, %{
      movies: movies.entries,
      pagination: %{
        total_entries: movies.total_entries,
        total_pages: movies.total_pages,
        page_number: movies.page_number,
        page_size: movies.page_size
      }
    })
  end

  def show(conn, %{"id" => id}) do
    movie = Repo.get!(Movie, id)
    |> Repo.preload(:directors)

    json(conn, %{movie: movie})
  end
end
