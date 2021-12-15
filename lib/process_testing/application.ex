defmodule ProcessTesting.Application do
  use Application

  alias ProcessTesting.PingPong

  def start(_type, _args) do
    {:ok, sup} = DynamicSupervisor.start_link(name: PingPongSupervisor, strategy: :one_for_one)

    ping_spec = PingPong.child_spec("ping", 10)
    {:ok, ping} = DynamicSupervisor.start_child(sup, ping_spec)

    pong_spec = PingPong.child_spec("pong", 10)
    {:ok, pong} = DynamicSupervisor.start_child(sup, pong_spec)

    # start the volley
    PingPong.volley_to(ping, pong)

    {:ok, sup}
  end
end
