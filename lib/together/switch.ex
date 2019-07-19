defmodule Together.Switch do
  use GenStateMachine

  def start_link(_) do
    GenStateMachine.start_link(__MODULE__, {:off, 0}, name: __MODULE__)
  end

  def flip() do
    GenStateMachine.cast(__MODULE__, :flip)
  end

  def get_count() do
    GenStateMachine.call(__MODULE__, :get_count)
  end

  # Callbacks

  def handle_event(:cast, :flip, :off, data) do
    {:next_state, :on, data + 1}
  end

  def handle_event(:cast, :flip, :on, data) do
    {:next_state, :off, data + 1}
  end

  def handle_event({:call, from}, :get_count, state, data) do
    {:next_state, state, data, [{:reply, from, {state, data}}]}
  end
end
