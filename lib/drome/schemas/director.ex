defmodule Drome.Schemas.Director do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :tmdb_id, :profile_path, :inserted_at, :updated_at]}

  schema "directors" do
    @timestamps_opts [type: :utc_datetime]

    field :name, :string
    field :tmdb_id, :integer
    field :profile_path, :string

    has_many :movie_directors, Drome.Schemas.MovieDirector
    many_to_many :movies, Drome.Schemas.Movie, join_through: "movie_directors"

    timestamps()
  end

  @doc false
  def changeset(director, attrs) do
    required_fields = [:name, :tmdb_id]
    optional_fields = [:profile_path]
    fields = required_fields ++ optional_fields

    director
    |> cast(attrs, fields)
    |> validate_required(required_fields)
  end

  def changeset_from_tmdb(director, tmdb_director) do
    director
    |> changeset(%{
      name: tmdb_director["name"],
      tmdb_id: tmdb_director["id"],
      profile_path: tmdb_director["profile_path"]
    })
  end
end
