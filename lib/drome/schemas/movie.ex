defmodule Drome.Schemas.Movie do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :title, :overview, :tagline, :poster_path, :backdrop_path, :release_date, :year, :runtime, :budget, :revenue, :tmdb_popularity, :tmdb_vote_count, :tmdb_vote_average, :inserted_at, :updated_at, :directors]}

  schema "movies" do
    @timestamps_opts [type: :utc_datetime]

    field :title, :string
    field :tagline, :string
    field :overview, :string
    field :runtime, :integer
    field :original_language, :string
    field :original_title, :string
    field :budget, :integer
    field :revenue, :integer
    field :release_date, :date
    field :year, :integer
    field :poster_path, :string
    field :backdrop_path, :string
    field :tmdb_id, :integer
    field :tmdb_popularity, :float
    field :tmdb_vote_average, :float
    field :tmdb_vote_count, :integer

    has_many :movie_directors, Drome.Schemas.MovieDirector
    many_to_many :directors, Drome.Schemas.Director, join_through: "movie_directors"

    timestamps()
  end

  @doc false
  def changeset(movie, attrs) do
    required_fields = [:title, :release_date, :tmdb_id]
    optional_fields = [
      :tagline, :overview, :runtime, :original_language, :original_title,
      :budget, :revenue, :year, :poster_path, :backdrop_path,
      :tmdb_popularity, :tmdb_vote_average, :tmdb_vote_count
    ]
    fields = required_fields ++ optional_fields

    movie
    |> cast(attrs, fields)
    |> validate_required(required_fields)
  end

  def changeset_from_tmdb(movie, tmdb_movie) do
    movie
    |> changeset(%{
      title: tmdb_movie["title"],
      tagline: tmdb_movie["tagline"],
      overview: tmdb_movie["overview"],
      runtime: tmdb_movie["runtime"],
      original_language: tmdb_movie["original_language"],
      original_title: tmdb_movie["original_title"],
      budget: tmdb_movie["budget"],
      revenue: tmdb_movie["revenue"],
      release_date: convert_date(tmdb_movie["release_date"]),
      year: String.split(tmdb_movie["release_date"], "-") |> hd |> String.to_integer,
      poster_path: tmdb_movie["poster_path"],
      backdrop_path: tmdb_movie["backdrop_path"],
      tmdb_id: tmdb_movie["id"],
      tmdb_popularity: tmdb_movie["popularity"],
      tmdb_vote_average: tmdb_movie["vote_average"],
      tmdb_vote_count: tmdb_movie["vote_count"]
    })
  end

  def struct_from_tmdb(tmdb_movie) do
    release_date = convert_date(tmdb_movie["release_date"])
    year =
      if(is_nil(release_date), do: nil,
      else: release_date.year)
    %{
      title: tmdb_movie["title"],
      tagline: tmdb_movie["tagline"],
      overview: tmdb_movie["overview"],
      runtime: tmdb_movie["runtime"],
      original_language: tmdb_movie["original_language"],
      original_title: tmdb_movie["original_title"],
      budget: tmdb_movie["budget"],
      revenue: tmdb_movie["revenue"],
      release_date: release_date,
      year: year,
      poster_path: tmdb_movie["poster_path"],
      backdrop_path: tmdb_movie["backdrop_path"],
      tmdb_id: tmdb_movie["id"],
      tmdb_popularity: tmdb_movie["popularity"],
      tmdb_vote_average: tmdb_movie["vote_average"],
      tmdb_vote_count: tmdb_movie["vote_count"],
      inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
      updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }
  end

  defp convert_date(date) do
    case Date.from_iso8601(date) do
      {:ok, date} -> date
      {:error, _} -> nil
    end
  end
end
