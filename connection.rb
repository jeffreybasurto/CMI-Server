require 'socket' # for unpack_sockaddr_in()

module MudConnection
  @connections = [] # connections to the server.

  def self.connections
    @connections
  end

  def post_init
    @port, @addr = Socket.unpack_sockaddr_in(get_peername)
    log :info, "---#{@addr} has connected."
    MudConnection.connections << self
  end

  # receives packets and acts upon them.
  def receive_data(incoming_data)
    # TODO need to make some way to capture and ensure a full packet is being sent.
    # Probably a delimiter but maybe just using the first 4 bytes for string length each time.
    packet = Packet.new(incoming_data)

    unless packet.is_valid?
      error = Packet.new ({"type"=>"error", "text"=>"#{incoming_data} was not valid."})
      send_data error.to_s
      log :info, "Packet from #{@addr} failed: #{incoming_data}"
      close_connection true
      return
    end

    # it's valid, so let's execute it.
    packet.execute
  end

  def unbind
    log :info, "---#{@addr} disconnected."
    MudConnection.connections.delete(self)
  end
end