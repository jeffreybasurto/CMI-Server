require 'yaml'

# a valid packet is formed with
# example of a valid packet..
class Packet
  def initialize data
    if data.is_a? String
      @data = YAML::load(data) rescue nil
    end

    if data.is_a? Hash
      @data = data
    end
  end

  # is this packet valid?
  def is_valid?
    case @data
      when Hash
        return true
    end
    return false # return false on anything else.
  end


  # do whatever this packet is designed to do right now.
  def execute
    case @data["type"]
      when "chat"
        MudConnection.connections.each do |socket|
          socket.send_data self.to_s
        end
    end
  end


  def to_s
    @data.to_yaml
  end
end