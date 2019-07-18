defmodule Hello do
  def run() do
    ch = Chan.new()

    spawn(fn ->
      for i <- 1..100 do
        Chan.send_msg(ch, i)
      end
    end)

    spawn(fn ->
      for i <- 200..300 do
        Chan.send_msg(ch, i)
      end
    end)

    spawn(fn ->
      Chan.recv_msg(ch, fn msg ->
        IO.puts("#{self() |> inspect} #{msg}")
        Process.sleep(1000)
      end)
    end)

    Process.sleep(200_000_000)
  end
end

defmodule Chan do
  def new() do
    spawn(fn ->
      main_loop(%{
        total: [],
        next: []
      })
    end)
  end

  def send_msg(ch, msg) do
    send(ch, {:msg, self(), msg})
    wait_ack()
  end

  defp wait_ack() do
    receive do
      :sent -> :ok
    end
  end

  def recv_msg(ch, func) do
    send(ch, {:registry, self()})
    recv_loop(func)
  end

  defp recv_loop(func) do
    receive do
      {:msg, from, msg} ->
        send(from, :sent)
        func.(msg)
    end

    recv_loop(func)
  end

  def main_loop(%{total: total} = recvs) do
    recvs =
      receive do
        {:msg, from, msg} ->
          recvs_ = do_send_msg(recvs, msg)
          ack(from)
          recvs_

        {:registry, recv} ->
          %{recvs | total: [recv | total]}
      end

    main_loop(recvs)
  end

  defp ack(from) do
    send(from, :sent)
  end

  defp do_send_msg(recvs, msg) do
    case recvs do
      %{total: []} ->
        recvs

      %{total: total, next: []} ->
        do_send_msg(%{recvs | next: total}, msg)

      %{next: [h | t]} ->
        e  )
        wait_ack()
        %{recvs | next: t}
    end
  end
end

Hello.run()
