defmodule Drome.Repo.Migrations.CreateMovies do
  use Ecto.Migration

  def change do
    create table(:movies) do
      add :title, :string
      add :tagline, :string
      add :overview, :text
      add :runtime, :integer

      add :original_language, :string
      add :original_title, :string

      add :budget, :integer
      add :revenue, :bigint

      add :release_date, :date
      add :year, :integer

      add :poster_path, :string
      add :backdrop_path, :string

      add :tmdb_id, :integer
      add :tmdb_popularity, :float
      add :tmdb_vote_average, :float
      add :tmdb_vote_count, :integer

      timestamps()
    end

    create unique_index(:movies, [:tmdb_id])
    create index(:movies, [:title])

    create table(:directors) do
      add :name, :string
      add :tmdb_id, :integer
      add :profile_path, :string
      timestamps()
    end

    create unique_index(:directors, [:tmdb_id])

    create table(:movie_directors) do
      add :movie_id, references(:movies, on_delete: :delete_all)
      add :director_id, references(:directors, on_delete: :delete_all)
      timestamps()
    end
  end
end
