defmodule Hello do
  def run() do
    Chan.new()
    |> send_msg({:msg, 1})
    |> send_msg("xxxx")
    |> send_msg({:msg, "xxx"})

    Process.sleep(20000)
  end

  defp send_msg(ch, msg) do
    send(ch, msg)
    ch
  end
end

defmodule Chan do
  def new do
    dispatcher =
      spawn(fn ->
        dispatch_loop()
      end)

    spawn(fn ->
      filter_loop(dispatcher)
    end)
  end



  defp dispatch_loop() do
    receive do
      {:msg, msg} ->
        IO.puts(msg)
    end
  end

  defp filter_loop(dispatcher) do
    receive do
      {:msg, msg} ->
        send(dispatcher, {:msg, msg})

      other ->
        IO.puts(other)
        :ok
    end

    filter_loop(dispatcher)
  end
end

Hello.run()
