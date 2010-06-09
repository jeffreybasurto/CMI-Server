
# Add files that need to be included.
%w[eventmachine].each {|file|  require file}
# Library to load
%w[log.rb connection.rb packet.rb].each {|file| load file}

$server_options = YAML::load_file("config/server_config.yml")

# Start receiving connections.
# Code inside of connection.rb handles incoming and outgoing data..
EventMachine::run {
  log :info, "Starting CMI on #{$server_options[:port]}."
  EventMachine::start_server "0.0.0.0", $server_options[:port], MudConnection
}
### Doesn't reach here unless the server is shutdown
log :info, "Server shutdown."
