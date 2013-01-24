require 'net/http'
require 'observer'

module Dino
  module TxRx
    class HTTP
      include Observable

      def initialize(host, port=80)
        @host, @port = host, port
      end

      def read
      end

      def close_read
      end

      def write(request)
        response = Net::HTTP.get(URI("http://#{@host}:#{@port}/#{request}"))
        unless response == "OK"
          pin, response = response.chomp.split(/::/)
          pin && response && changed && notify_observers(pin, response)
        end
      rescue
        raise BoardNotFound
      end
    end
  end
end
