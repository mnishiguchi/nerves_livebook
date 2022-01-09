defmodule HelloNervesSubscriber do
  @moduledoc """
  Receives sensor measurements from the HelloNerves firmware via KantanCluster's
  pub-sub. It stores one last measurement.
  """

  use GenServer, restart: :transient

  defstruct last_measurement: nil

  @pubsub_topic "hello_nerves:measurements"

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def measurement do
    GenServer.call(__MODULE__, :measurement)
  end

  @impl GenServer
  def init(_opts) do
    KantanCluster.subscribe(@pubsub_topic)

    {:ok, __struct__()}
  end

  @impl GenServer
  def handle_call(:measurement, _from, state) do
    {:reply, state.last_measurement, state}
  end

  @impl GenServer
  def handle_info({:hello_nerves_measurement, measurement, _node}, state) do
    {:noreply, %{state | last_measurement: measurement}}
  end

  @impl GenServer
  def handle_info(msg, _state) do
    Phoenix.PubSub.unsubscribe(HelloNerves, @pubsub_topic)
    raise("Unexpected message received: #{inspect(msg)}")
  end
end
