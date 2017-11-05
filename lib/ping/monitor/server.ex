defmodule Ping.Monitor.Server do
  use GenServer
  alias Ping.Monitor.Check
  # API

  def start_link(ip_address, status, check_frequency) do
    GenServer.start_link(__MODULE__, %{ip_address: ip_address, status: status, check_frequency: check_frequency}, name: via_tuple(ip_address))
  end

  defp via_tuple(ip_address) do
    {:via, :gproc, {:n, :l, {:host_monitor, ip_address}}}
  end

  def get_state(ip_address) do
    GenServer.call(via_tuple(ip_address), :get_state)
  end

  # SERVER

  def init(initial_state) do
    state = %{
      ip_address: initial_state.ip_address,
      status: initial_state.status,
      latency: 0,
      online_counter: 0,
      offline_counter: 0,
      check_frequency: initial_state.check_frequency
    }

    schedule_work(state.check_frequency)
    {:ok, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:work, state) do
    new_state =
      with {:ok, results} <- Check.host_up(state.ip_address) do
        state
        |> apply_results(results)
        |> detect_status_transition()
      else
        {:error, error} ->
          IO.puts "An error occured"
          error
      end

      schedule_work(state.check_frequency)
    {:noreply, new_state}
  end

  defp apply_results(state, results) do
    case {state.status, results.status} do
      {"initial", current} -> %{state | status: current, latency: results.latency}
      {"online", "offline"} -> %{state | offline_counter: state.offline_counter + 1, latency: results.latency}
      {"offline", "online"} -> %{state | online_counter: state.online_counter + 1, latency: results.latency}
      _ -> %{state | latency: results.latency}
    end
  end

  defp detect_status_transition(%{online_counter: counter} = state) when counter > 3 do
    # Notify online here
    %{state | status: "online", online_counter: 0, offline_counter: 0}
  end
  defp detect_status_transition(%{offline_counter: counter} = state) when counter > 3 do
    # Notify offline here
    %{state | status: "offline", offline_counter: 0, offline_counter: 0}
  end
  defp detect_status_transition(state), do: state

  defp schedule_work(check_frequency) do
    Process.send_after(self(), :work, check_frequency)
  end
end
