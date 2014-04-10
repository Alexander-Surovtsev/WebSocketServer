require 'eventmachine'
require 'em-websocket'
require_relative 'gameController'

@gc = GameController.new

EventMachine.run do
  EventMachine::WebSocket.start(:host => '0.0.0.0', :port => 8081) do |socket|
    socket.onopen do
      @gc.addSocket(socket)
    end
    socket.onmessage do |mess|
    #  @gc.sockets.each {|s| s.send mess}
      @gc.processMessage(socket, mess)
    end
    socket.onclose do
      @gc.deleteSocket(socket)
    end
  end
end