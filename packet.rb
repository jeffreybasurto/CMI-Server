require 'yaml'
# a valid packet is formed with
class Packet
  # These are the expected types per each packet type.
  # packet is a fail if these packets do not exist.
  @expected = YAML::load_file("config/packet_config.yml")
  class << self; attr_accessor :expected; end
  attr_accessor :data

  def initialize data
    if data.is_a? String
      @data = YAML::load(data) rescue nil
    else
      @data = data
    end
  end

  def self.notify of, txt
    Packet.new({"type"=>"notify", "event"=>of, "text"=>txt})
  end

  def self.error txt
    Packet.new({"type"=>"error", "text"=>txt, "from"=>"server"})
  end


  # is this packet valid?
  def is_invalid?
    case @data
      when Hash
        type = @data["type"]

        return Packet.error("Packet type not included.") if type == nil
        return Packet.error("Packet type of #{type} not valid.") if !Packet.expected[type]

        Packet.expected[type].each do |expected|
          return Packet.error("Expected data of type #{expected} was not included.") if !@data[expected]
        end
        return false
    end
    return Packet.error "Erroneous data type for packet." # return false on anything else.
  end

  # do whatever this packet is designed to do right now.
  def execute socket
    case @data["type"]
      when "chat"
        MudConnection.connections.each do |socket|
          socket.send_data self.to_s
        end
      when "login"    
        socket.validated, socket.mud = true, @data["mud"] 

        MudConnection.connections.each do |socket|
          socket.send_data Packet.notify("login", @data["mud"]).to_s
        end
    end
  end
  def to_s
    @data.to_yaml
  end
end
