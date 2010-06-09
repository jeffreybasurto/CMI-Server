
# Add files that need to be included.
%w[eventmachine].each {|file|  require file}
# Library to load
%w[log.rb connection.rb packet.rb].each {|file| load file}

$connections = [] # connections to the server.

# Start receiving connections.
# Code inside of connection.rb handles incoming and outgoing data..
EventMachine::run {
  EventMachine::start_server "0.0.0.0", 5000, MudConnection
}
### Doesn't reach here unless the server is shutdown
log :info, "Server shutdown."