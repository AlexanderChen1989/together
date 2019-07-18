defmodule Main do
  def run() do
    ch =
      Chan.new(fn msg ->
        "Hello #{msg}" |> IO.puts()
      end)

    for i <- 1..100 do
      Chan.send_msg(ch, i)
    end
    Process.sleep(100000)
  end
end

defmodule Chan do
  def new(func) do
    spawn(fn -> loop(func) end)
  end

  def send_msg(ch, msg) do
    send(ch, {:msg, msg})
  end

  defp loop(func) do
    receive do
      event -> process(func, event)
    end

    loop(func)
  end

  defp process(func, {:msg, msg}) do
    func.(msg)
  end

  defp process(func, _), do: :ok
end

Main.run()
