defmodule Ping.Monitor.Check do
  @moduledoc """
  Module to ping IP addresses
  https://github.com/seven1m/30-days-of-elixir/blob/master/09-ping.exs
  """

  def ping_args(ip) do
    ["-c", "1", "-t", "2", ip]
  end

  def host_up(ip_address) do
    # This is a Ruby-ish way of dealing with failure...
    # Discover the "Elixir way"
      # return code should be handled somehow with pattern matching
    {cmd_output, _} = System.cmd("ping", ping_args(ip_address))

    latency =
      case Regex.run(~r/(?<=time=)(.*)(?=\.)/, cmd_output) do
        [_ | timeout] -> String.to_integer(Enum.fetch!(timeout, 0))
        _ -> 0
      end

    status =
      case latency do
        0 -> "offline"
        _ -> "online"
      end

    {:ok, %{ip_address: ip_address, time: :os.system_time(:seconds), latency: latency, status: status}}
  rescue
    e -> {:error, e}
  end
end
