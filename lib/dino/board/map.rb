require 'yaml'

module Dino
  class Board
    MAPS_FOLDER = File.join(Dino.root, "vendor/board-maps/yaml")

    attr_reader :map
    
    def load_map(board_name)
      if board_name
        map_path = File.join(MAPS_FOLDER, "#{board_name}.yml")
        @map = YAML.load_file(map_path)
      else
        @map = nil
      end
    rescue
      raise StandardError, "error loading board map from file for board name: '#{board_name}'"
    end
    
    def convert_pin(pin)
      # Handle special case of built-in EEPROM "pin".
      return "EE" if pin == "EE"

      # Convert non numerical strings to symbols.
      pin = pin.to_sym if (pin.class == String) && !(pin.match /\A\d+\.*\d*/)

      # Handle symbols.
      if (pin.class == Symbol)
        if map && map[pin]
          return map[pin]
        elsif map
          raise ArgumentError, "error in pin: #{pin.inspect}. Make sure that pin is defined for this board by calling Board#map"
        else
          raise ArgumentError, "error in pin: #{pin.inspect}. Given a Symbol, but board has no map. Try using GPIO integer instead"
        end
      end

      # Handle integers.
      return pin if pin.class == Integer

      # Try #to_i on anyting else. Will catch numerical strings.
      begin
        return pin.to_i
      rescue => exception
        raise ArgumentError, "error in pin: #{pin.inspect}"
      end
    end
  end
end
