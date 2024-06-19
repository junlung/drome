# Use an official Elixir runtime as a parent image
FROM elixir:latest

# Set the working directory
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && mix local.rebar --force

# Copy the Elixir project files to the container
COPY . .

# Install dependencies
RUN mix deps.get

# Compile the application
RUN mix compile

# Build the release
RUN mix release

# Expose the port the app runs on
EXPOSE 4000

# Run the Phoenix server
CMD ["_build/prod/rel/drome/bin/your_app_name", "start"]