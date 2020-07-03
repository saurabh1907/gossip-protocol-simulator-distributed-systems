defmodule App do
  use GenServer

  def main(args) do
    [numNodes, topology, algorithm] = args
    Registry.start_link(keys: :unique, name: :my_reg)

    total_nodes = get_effective_total_nodes(numNodes, topology)

    peer_list = Enum.to_list(1..total_nodes)

    initialize_ets(length(peer_list))

    if(topology=="rand2D") do
      create_random_grid(total_nodes)
    end

    case algorithm do
      "gossip" -> create_gossip_peers(peer_list, topology)
                  initiate_gossip_msg(peer_list)
      "push-sum" -> create_pushsum_peers(peer_list, topology)
                    initiate_pushsum_msg(peer_list)
    end
    infiniteloop() #not needed if running from iex
  end

  def infiniteloop() do
    :timer.sleep(100)
    infiniteloop()
  end
  def init(state) do
    {:ok, state}
  end

  def create_gossip_peers(peer_list, topology_name) do
    Enum.each peer_list, fn peer ->
      {:ok, pid} = GenServer.start_link(GossipPeer, %{seen_count: 0, name: peer, topology: topology_name},
      name: via_tuple(Integer.to_string(peer)))
    end
  end

  def create_pushsum_peers(peer_list, topology_name) do
    Enum.each peer_list, fn peer ->
      {:ok, pid} = GenServer.start_link(PushSumPeer, %{no_change_counter: 0, name: peer, topology: topology_name, s: peer/1, w: 1.0},
      name: via_tuple(Integer.to_string(peer)))
    end
  end

  def initiate_gossip_msg(peer_list) do
    random_node = Enum.random(peer_list)
    GenServer.cast(via_tuple(Integer.to_string(random_node)),{:receive,:ok})
  end

  def initiate_pushsum_msg(peer_list) do
    random_node = Enum.random(peer_list)
    GenServer.cast(via_tuple(Integer.to_string(random_node)),{:receive,0,0})
  end

  defp initialize_ets(peer_count) do
    datastore = :ets.new(:datastore, [:set, :public, :named_table])
    :ets.insert(datastore, {"count",0})
    :ets.insert(datastore, {"total_nodes",peer_count})
    :ets.insert(datastore, {"start_time",System.monotonic_time(:millisecond)})
  end

  def get_effective_total_nodes(total_nodes, topology) do
    total_nodes = String.to_integer(total_nodes)
    case topology do
      "full" -> total_nodes
      "line" -> total_nodes
      "3Dtorus" -> total_nodes |> :math.pow(1 / 3) |> :math.ceil() |>:math.pow(3) |> trunc()
      _ -> total_nodes |> :math.pow(1 / 2) |> :math.ceil() |>:math.pow(2) |> trunc()
    end
  end

  def create_random_grid(total_nodes) do
    random2dGrid = Enum.shuffle(1..total_nodes) |> Enum.with_index(1)
    :ets.insert(:datastore, {"random2dGrid",random2dGrid})
  end

  defp via_tuple(peer_name) do
    {:via, Registry, {:my_reg, peer_name}}
  end
end
