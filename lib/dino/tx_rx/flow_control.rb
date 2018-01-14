module Dino
  module TxRx
    module FlowControl
      BOARD_BUFFER = 64
      SLEEP_UPDATE_INTERVAL = 0.1
      SLEEP_MIN = 0.00015625
      SLEEP_MAX = 0.01

      def initialize(*args)
        reset_flow_control
        super(*args)
      end

      def write(message)
        add_write_call
        @write_mutex.synchronize do
          while message && !message.empty?
            bytes = reserve_bytes(message.length)
            if bytes > 0
              fragment = message[0..(bytes-1)]
              message = message[bytes..-1]
              super(fragment)
            else
              tx_wait
            end
          end
        end
      end

      # Keep the transit mutex lock for as little time as possible this way.
      def reserve_bytes(length)
        @transit_mutex.synchronize do
          available = BOARD_BUFFER - @transit_bytes
          reserved = (length > available) ? available : length
          @transit_bytes += reserved
          reserved
        end
      end

    private

      def reset_flow_control
        @write_mutex    ||= Mutex.new
        @transit_mutex  ||= Mutex.new
        @tx_sleep_mutex ||= Mutex.new
        @rx_sleep_mutex ||= Mutex.new
        @transit_mutex.synchronize { @transit_bytes = 0 }

        @tx_sleep_mutex.synchronize do
          @tx_sleep        = SLEEP_MAX
          @write_calls     = 0
          @tx_sleep_calls  = 0
        end

        @rx_sleep_mutex.synchronize do
          @rx_sleep        = SLEEP_MAX
          @read_lines      = 0
          @rx_sleep_calls  = 0
        end

        @last_interval_update = Time.now
      end

      def read_and_process
        line = read

        if line && line.match(/\AACK:/)
          # Handle handshake responses by passing to the observing HandshakeAttempt.
          # Also pass self so it can detach itself when done.
          changed && notify_observers(self, line.split(":", 2)[1])
          # Empty transit counter since ACK: won't also send RCV:
          @transit_mutex.synchronize { @transit_bytes = 0 }
        elsif line && line.match(/\ARCV:/)
          remove_transit_bytes(line.split(/:/)[1].to_i)
        elsif line
          process(line)
        else
          rx_wait
        end

        add_read_line if line
        update_sleep_intervals
      end

      def update_sleep_intervals
        if (Time.now - @last_interval_update > SLEEP_UPDATE_INTERVAL)
          @last_interval_update = Time.now
          update_rx_sleep_interval
          update_tx_sleep_interval
        end
      end

      def update_tx_sleep_interval
        @tx_sleep_mutex.synchronize do
          if (@write_calls > 0) && (@tx_sleep_calls.to_f/@write_calls.to_f > 0.1)
            @tx_sleep /= 2 if (@tx_sleep > SLEEP_MIN)
          else
            @tx_sleep *= 2 if (@tx_sleep < SLEEP_MAX)
          end
          @write_calls = 0
          @tx_sleep_calls = 0
        end
      end

      def update_rx_sleep_interval
        @rx_sleep_mutex.synchronize do
          if (@read_lines > 0) && (@read_lines.to_f/@rx_sleep_calls.to_f > 0.01)
            @rx_sleep /= 2 if (@rx_sleep > SLEEP_MIN)
          else
            @rx_sleep *= 2 if (@rx_sleep < SLEEP_MAX)
          end
          @read_lines = 0
          @rx_sleep_calls = 0
        end
      end

      def add_write_call
        @tx_sleep_mutex.synchronize { @write_calls += 1 }
      end

      def add_read_line
        @rx_sleep_mutex.synchronize { @read_lines += 1 }
      end

      def rx_wait
        @rx_sleep_mutex.synchronize { @rx_sleep_calls += 1 }
        sleep @rx_sleep
      end

      def tx_wait
        @tx_sleep_mutex.synchronize { @tx_sleep_calls += 1 }
        sleep @tx_sleep
      end

      def add_transit_bytes(value)
        @transit_mutex.synchronize { @transit_bytes = @transit_bytes + value }
      end

      def remove_transit_bytes(value)
        @transit_mutex.synchronize { @transit_bytes = @transit_bytes - value }
      end
    end
  end
end
