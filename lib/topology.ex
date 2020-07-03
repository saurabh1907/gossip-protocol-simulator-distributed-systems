defmodule Topology do
  def getNeighbor(topology, curr_index) do
    total_nodes = elem(Enum.at(:ets.lookup(:datastore, "total_nodes"),0),1)
    neighbors =
      case topology do
        "full" -> get_full_neighbors(total_nodes)

        "line" -> get_line_neighbors(curr_index, total_nodes)

        "rand2D" -> get_rand2D_neighbors(curr_index, total_nodes)

        "3Dtorus" -> get_3Dtorus_neighbors(curr_index, total_nodes)

        "honeycomb" -> get_honeycomb_neighbors(curr_index, total_nodes)

        "randhoneycomb" -> get_randhoneycomb_neighbors(curr_index, total_nodes)
      end
      neighbors
  end

  defp get_full_neighbors(total_nodes) do
    Enum.to_list 1..total_nodes
  end

  defp get_line_neighbors(curr_index, total_nodes) do
    cond do
      curr_index == 1 -> [2]
      curr_index == total_nodes ->[total_nodes - 1]
      true -> [(curr_index - 1), (curr_index + 1)]
    end
  end

  defp get_3Dtorus_neighbors(i, total_nodes) do
    cubeLength = total_nodes |> :math.pow(1 / 3) |> :math.ceil() |> trunc()

    side1 = if i - cubeLength <= 0, do: i + cubeLength * cubeLength - cubeLength , else: i - 1
    side2 = if i + cubeLength > total_nodes, do: i - cubeLength * cubeLength + cubeLength, else: i + 1
    side3 = if rem(i,cubeLength) == 0, do: i - cubeLength + 1, else: i + 1
    side4 = if rem(i,cubeLength) == 1, do: i + cubeLength - 1, else: i - 1
    side5 = if div(i - 1, cubeLength * cubeLength) == 0, do: i + total_nodes - cubeLength * cubeLength, else: i - cubeLength * cubeLength
    side6 = if div(i - 1, cubeLength * cubeLength) == (cubeLength - 1), do: i - total_nodes + cubeLength * cubeLength, else: i + cubeLength * cubeLength
    [
      side1,side2,side3,side4,side5,side6
    ]
  end

  def get_honeycomb_neighbors(curr_index, total_nodes) do
      width = total_nodes |> :math.pow(1 / 2) |> :math.ceil() |> trunc()
      row = div(curr_index-1, width)
      neighbors1 =
        if(rem(width, 2)==0) do #grid even width
          if(rem(row, 2) == 0) do #even row
            cond do
              rem(curr_index,width)==1 || rem(curr_index,width)==0 -> -1
              rem(curr_index,2)==0 -> curr_index + 1
              rem(curr_index,2)==1 -> curr_index - 1
            end
          else
            cond do
              rem(curr_index,2)==0 -> curr_index - 1
              rem(curr_index,2)==1 -> curr_index + 1
            end
          end
        else #grid odd width
          if(rem(row, 2) == 0) do
            cond do
              rem(curr_index,width)==1 -> -1
              rem(curr_index,2)==0 -> curr_index + 1
              rem(curr_index,2)==1 -> curr_index - 1
            end
          else
            cond do
              rem(curr_index,width)==0 -> -1
              rem(curr_index,2)==0 -> curr_index + 1
              rem(curr_index,2)==1 -> curr_index - 1
            end
          end
        end
      neighbors2 = curr_index + width
      neighbors3 = curr_index - width
      [
        neighbors1,neighbors2,neighbors3
      ]
      |> Enum.filter(fn x -> x > 0 && x <= total_nodes end) |> Enum.map(fn x-> trunc(x) end)
  end

  defp get_randhoneycomb_neighbors(curr_index, total_nodes) do
    [Enum.random(1..total_nodes) | get_honeycomb_neighbors(curr_index, total_nodes)]
  end

  def get_rand2D_neighbors(curr_index, total_nodes) do
    random_2d_grid = elem(Enum.at(:ets.lookup(:datastore, "random2dGrid"),0),1)

    gridLen = total_nodes |> :math.sqrt() |> trunc()
    if(gridLen >= 10)do
      k = (gridLen / 10) |> :math.ceil() |> trunc()

      top = Enum.map(1..k, fn x -> curr_index - x * gridLen end) |> Enum.filter(fn x -> x > 0 end)
      bottom = Enum.map(1..k, fn x -> curr_index + x * gridLen end) |> Enum.filter(fn x -> x <= total_nodes end)

      right =
        if rem(curr_index, gridLen) == 0,
          do: [],
          else: Enum.take_while((curr_index + 1)..(curr_index + k), fn x -> rem(x, gridLen) != 1 end)

      left =
        if rem(curr_index, gridLen) == 1,
          do: [],
          else: Enum.take_while((curr_index - 1)..(curr_index - k), fn x -> rem(x, gridLen) != 0 end)

      neighborIndex = top ++ bottom ++ right ++ left |> Enum.map(fn x -> trunc(x) end)

      neighbors = Enum.filter(random_2d_grid, fn x -> Enum.member?(neighborIndex, elem(x, 1)) end)
      |> Enum.map(fn x -> elem(x, 0) end)
    else
      []
    end
  end

  def get_distance(x1, y1, x2, y2) do
    :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
  end
end

