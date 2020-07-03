defmodule GossipPeer do
  use GenServer

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:receive, msg}, state) do
    seen_count = state.seen_count + 1

    if (seen_count == 1) do
      #Start gossip mode on the peer asynchronously
      spawn_link(__MODULE__,:gossip_cycle,[state])

      count = :ets.update_counter(:datastore, "count", {2,1})
      total_nodes = elem(Enum.at(:ets.lookup(:datastore, "total_nodes"),0),1)
      # print for every x nodes that received msg
      if(rem(count,trunc(total_nodes/10))==0) do
        IO.puts("Nodes seen message = #{count}")
      end

      if count == total_nodes do
        start_time = elem(Enum.at(:ets.lookup(:datastore, "start_time"),0),1)
        endTime = System.monotonic_time(:millisecond) - start_time
        IO.puts "Convergence time = " <> Integer.to_string(endTime) <>" Milliseconds"
        System.halt(1)
      end
    end

    if (seen_count >= 10) do
      exit(:normal)
    end

    updated_state = Map.put(state,:seen_count, seen_count)
    {:noreply, updated_state}
  end

  def gossip_cycle(state) do
    curr_index = state.name
    neighbors = Topology.getNeighbor(state.topology, curr_index)

    target = Integer.to_string(find_random_neighbor(neighbors))
    GenServer.cast(via_tuple(target), {:receive,:ok})
    gossip_cycle(state)
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
