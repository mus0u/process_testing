defmodule ProcessTesting.PingPong do
  use GenServer

  require Logger

  # public interface

  def volley_to(opponent, from \\ nil) do
    GenServer.cast(opponent, {:volley_to, from || self()})
  end

  def volley_count(opponent) do
    GenServer.call(opponent, :volley_count)
  end

  def child_spec(racket_noise \\ "ping", max_volleys \\ :infinity) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, [racket_noise, max_volleys]}}
  end

  def start_link(racket_noise \\ "ping", max_volleys \\ :infinity) do
    GenServer.start_link(
      __MODULE__,
      %{noise: racket_noise, max_volleys: max_volleys, volley_count: 0}
    )
  end

  # GenServer callbacks

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast(
        {:volley_to, opponent},
        %{noise: noise, max_volleys: max, volley_count: count} = state
      ) do
    Logger.info("#{inspect(self())}: #{noise} #{count}")
    Process.sleep(1_000)

    if count < max do
      volley_to(opponent)
    else
      Logger.info("#{inspect(self())}: tired out...")
    end

    new_state = Map.put(state, :volley_count, count + 1)

    {:noreply, new_state}
  end

  @impl true
  def handle_call(:volley_count, _from, state) do
    {:reply, state[:volley_count], state}
  end
end
