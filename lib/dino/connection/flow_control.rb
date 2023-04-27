module Dino
  module Connection
    module FlowControl
      BOARD_BUFFER = 64
      SLEEP_UPDATE_INTERVAL = 0.1
      SLEEP_MIN = 0.00015625
      SLEEP_MAX = 0.01

      def initialize(*args)
        super(*args)
        reset_flow_control
        tx_resume
      end

      def write(message, tx_halt_after=nil)
        add_write_call
        @write_buffer_mutex.synchronize do
          @write_buffer << message

          # Optionally halt transmission after this message.
          # See comments on Board#write_and_halt for more info.
          @tx_halt_points << @write_buffer.length if tx_halt_after
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
          @tx_halt_points = []
        end

        @last_interval_update = Time.now
      end
      
      def write_from_buffer
        fragment = nil
        halt_after_fragment = false

        @write_buffer_mutex.synchronize do
          # Nothing to write.
          break if @write_buffer.empty?

          # Try to send the entire buffer unless a halt point is coming up.
          if @tx_halt_points.empty?
            limit = @write_buffer.length
          # Don't send beyond the first halt point if one is.
          else
            limit = @tx_halt_points[0]
          end
          # Try to reserve limit bytes on the remote read buffer.
          bytes = reserve_bytes(limit)

          if bytes > 0
            # Take fragment of bytes length off the write buffer.
            fragment = @write_buffer[0..(bytes-1)]
            @write_buffer = @write_buffer[bytes..-1]

            # Update the halt points to reflect bytes removed.
            @tx_halt_points.map! { |length| length - bytes }

            # If the first halt point was reached, delete it, and halt after writing fragment.
            if @tx_halt_points[0] == 0
              @tx_halt_points.shift
              halt_after_fragment = true
            end
          end
        end

        # If no fragment, wait.
        return tx_wait unless fragment

        # If fragment, write it.
        loop do
          # Write and end loop if the board is ready.
          @io_mutex.synchronize do
            if @board_ready
              _write fragment
              @board_ready = false if halt_after_fragment
              return
            end
          end
          # Else wait outside the @io_mutex. Allow read thread to update @board_ready.
          tx_wait
        end
      end

      # Keep transit mutex as short as possible, by only reserving bytes, and writing outside.
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

          # Board says to resume transmission.
          if line.match(/\ARdy/)
            tx_resume
            line = nil
          # Board says to halt transmission.
          elsif line.match(/\AHlt/)
            tx_halt
            line = nil
          # Board read (freed) this many bytes from its input buffer.
          elsif line.match(/\ARx/)
            remove_transit_bytes(line.split(/x/)[1].to_i)
            line = nil
          elsif line.match(/\ADBG:/)
            puts line.inspect
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

      def tx_halt
        @io_mutex.synchronize { @board_ready = false } 
      end

      def tx_resume
        @io_mutex.synchronize { @board_ready = true }
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
