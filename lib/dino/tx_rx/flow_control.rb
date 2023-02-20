module Dino
  module TxRx
    module FlowControl
      BOARD_BUFFER = 64
      SLEEP_UPDATE_INTERVAL = 0.1
      SLEEP_MIN = 0.00015625
      SLEEP_MAX = 0.01

      def initialize(*args)
        super(*args)
        reset_flow_control
      end

      def write(message)
        add_write_call
        @write_buffer_mutex.synchronize do
          @write_buffer << message
        end
      end
      
      def writing?
        @write_buffer_mutex.synchronize { !@write_buffer.empty? }
      end

    private

      def reset_flow_control
        @io_mutex       ||= Mutex.new
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
        
        @write_buffer_mutex ||= Mutex.new
        @write_buffer_mutex.synchronize do
          @write_buffer = ""
        end

        @last_interval_update = Time.now
      end
      
      def write_from_buffer
        fragment = nil
        
        # Check space on the remote read buffer. If available, take a fragment
        # of that many bytes off the local write buffer.
        @write_buffer_mutex.synchronize do
          break if @write_buffer.empty?
          bytes = reserve_bytes(@write_buffer.length)
          if bytes > 0
            fragment = @write_buffer[0..(bytes-1)]
            @write_buffer = @write_buffer[bytes..-1]
          end
        end
        
        # Write if we can. Wait otherwise.
        if fragment
          @io_mutex.synchronize { _write fragment }
        else
          tx_wait
        end
      end

      # Use transit mutex for as short as possible by reserving bytes and writing later.
      def reserve_bytes(length)
        @transit_mutex.synchronize do
          available = BOARD_BUFFER - @transit_bytes
          reserved = (length > available) ? available : length
          @transit_bytes += reserved
          reserved
        end
      end

      def read
        line = @io_mutex.synchronize { _read }
        
        if line
          add_read_line
          if line.match(/\ARx/)
            remove_transit_bytes(line.split(/x/)[1].to_i)
            line = nil
          end
        else
          rx_wait
        end
        update_sleep_intervals
        
        return line
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
