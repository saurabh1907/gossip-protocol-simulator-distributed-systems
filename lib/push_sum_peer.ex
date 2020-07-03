defmodule PushSumPeer do
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:receive, s_received,w_received}, state) do
    s_new = state.s + s_received
    w_new = state.w + w_received

    change = abs(s_new/w_new - state.s/state.w)

    no_change_counter =
      if(change  < :math.pow(10,-10)) do
        state.no_change_counter+1
      else
        0
      end

    if(no_change_counter == 3) do
      count = :ets.update_counter(:datastore, "count", {2,1})
      total_nodes = elem(Enum.at(:ets.lookup(:datastore, "total_nodes"),0),1)

      # print for every x nodes that received msg
      if(rem(count,trunc(total_nodes/10))==0) do
        IO.puts("Peer count that remained unchanged 3 times = #{count}")
      end

      if count == total_nodes do
        start_time = elem(Enum.at(:ets.lookup(:datastore, "start_time"),0),1)
        endTime = System.monotonic_time(:millisecond) - start_time
        IO.puts("s value #{state.s}, w value #{state.w} at convergence for total nodes: #{total_nodes}")
        IO.puts "Convergence time = " <> Integer.to_string(endTime) <>" Milliseconds"
        System.halt(1)
      end
      # exit(:normal)
    end

    pushsum_send(state,s_new,w_new)

    updated_state = Map.put(state,:s, s_new/2)
    updated_state = Map.put(updated_state,:w, w_new/2)
    updated_state = Map.put(updated_state,:no_change_counter, no_change_counter)

    {:noreply, updated_state}
  end

  @spec pushsum_send(atom | %{name: any, topology: <<_::32, _::_*8>>}, number, number) :: :ok
  def pushsum_send(state,s_new,w_new) do
    curr_index = state.name
    neighbors = Topology.getNeighbor(state.topology, curr_index)
    target = Integer.to_string(find_random_neighbor(neighbors))
    GenServer.cast(via_tuple(target), {:receive, s_new/2, w_new/2})
  end

  def find_random_neighbor(neighbors) do
    if Enum.empty?(neighbors) do
      Process.exit(self(),:normal)
    end
    next = Enum.random(neighbors)
  end

  defp via_tuple(peer_name) do
    {:via, Registry, {:my_reg, peer_name}}
  end
end
