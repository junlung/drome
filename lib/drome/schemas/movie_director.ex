defmodule Drome.Schemas.MovieDirector do
  use Ecto.Schema
  import Ecto.Changeset

  schema "movie_directors" do
    @timestamps_opts [type: :utc_datetime]

    belongs_to :movie, Drome.Schemas.Movie
    belongs_to :director, Drome.Schemas.Director

    timestamps()
  end

  @doc false
  def changeset(movie_director, attrs) do
    required_fields = [:movie_id, :director_id]
    fields = required_fields

    movie_director
    |> cast(attrs, fields)
    |> validate_required(required_fields)
  end
end
