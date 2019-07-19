defmodule Together.StateMachine do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def hello(name) do
    GenServer.call(__MODULE__, {:hello, name})
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:hello, name}, _from, state) do
    {:reply, "Hello, #{name}!", state}
  end
end
