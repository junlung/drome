defmodule Drome.Tasks.TaskQueue do
  use GenServer

  @max_concurrent_tasks 5

  def start_link(_) do
    GenServer.start_link(__MODULE__, {[], 0}, name: __MODULE__)
  end

  def add_task(task) do
    GenServer.call(__MODULE__, {:add_task, task})
  end

  def task_completed do
    GenServer.cast(__MODULE__, {:task_completed})
  end

  def init(_) do
    {:ok, {[], 0}}
  end

  def handle_call({:add_task, task}, {queue, task_count}) do
    queue = [task | queue]
    if task_count < @max_concurrent_tasks do
      GenServer.cast(__MODULE__, :execute_next_task)
    end
    {:reply, :ok, {queue, task_count}}
  end

  def handle_info(:execute_next_task, {queue, task_count}) when task_count < @max_concurrent_tasks do
    [task | rest] = queue
    Task.Supervisor.async_nolink(Drome.Tasks.TaskSupervisor, task)
    {:noreply, {rest, task_count + 1}}
  end

  def handle_info(:execute_next_task, state), do: {:noreply, state}

  def handle_info({:task_completed}, {queue, task_count}) do
    GenServer.cast(__MODULE__, :execute_next_task)
    {:noreply, {queue, task_count - 1}}
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:get_queue_size, _from, {queue, _task_count}) do
    {:reply, length(queue), {queue, 0}}
  end
end
