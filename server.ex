defmodule SimpleHTTPServer do
  @port 4000
  @response """
  HTTP/1.1 200 OK\r
  Content-Type: application/json\r
  Content-Length: 20\r
  \r
  {"message": "hello"}
  """

  def start do
    {:ok, listen_socket} = :gen_tcp.listen(@port, [:binary, packet: :raw, active: false, reuseaddr: true])
    IO.puts("Listening on port #{@port}")
    accept_connections(listen_socket)
  end

  defp accept_connections(socket) do
    {:ok, client_socket} = :gen_tcp.accept(socket)
    Task.start(fn -> handle_client(client_socket) end)
    accept_connections(socket)
  end

  defp handle_client(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, _request} ->
        :gen_tcp.send(socket, @response)
        :gen_tcp.close(socket)
      {:error, _reason} ->
        :gen_tcp.close(socket)
    end
  end
end

SimpleHTTPServer.start()
