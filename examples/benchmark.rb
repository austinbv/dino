#
# This is a simple example to blink an led
# every half a second
#

require File.expand_path('../../lib/dino', __FILE__)
txrx = Dino::TxRx.new
# txrx = Dino::TxRx::TCP.new("192.168.0.77")
# txrx = Dino::TxRx::TCP.new("192.168.0.143", 3001) # ; txrx.io; sleep 5
board = Dino::Board.new(txrx)

txrx.write("!9800003.")

# Warm up
sleep 2

counter_analog = 0
counter_digital = 0
count_analog_responses = Proc.new { counter_analog = counter_analog + 1 }
test_time = 4

puts "Starting tests..."

(5..9).each do |digital_count|
  (0..5).each do |analog_count|

    # Setup hardware
    (0..analog_count).each do |pin|
      eval "$sensor#{pin} = Dino::Components::Sensor.new(pin: 'A#{pin}', board: board)"
      eval "$sensor#{pin}.when_data_received(count_analog_responses)"
    end
    (5..digital_count).each do |pin|
      eval "$digital#{pin} = Dino::Components::Button.new(pin: '#{pin}', board: board, pullup: true)"
      eval "$digital#{pin}.up   { counter_digital = counter_digital + 1 }"
      eval "$digital#{pin}.down { counter_digital = counter_digital + 1 }"
    end
    
    # Pre-test measurement
    state1_digital = counter_digital
    state1_analog = counter_analog

    # Wait
    sleep test_time

    # Post-test measurement
    state2_digital = counter_digital
    state2_analog = counter_analog

    # Calculation
    diff_digital = state2_digital - state1_digital
    diff_analog = state2_analog - state1_analog

    # Print
    print "#{digital_count -4}D/#{analog_count + 1}A Components: "
    print  "#{diff_digital/(test_time * (digital_count - 4))}Hz"
    print "/"
    print  "#{diff_analog/(test_time * (analog_count + 1))}Hz per component | "
    puts  "#{(diff_digital + diff_analog)/(test_time)} responses/s overall"

    # Remove hardware
    (0..analog_count).each do |pin|
      board.remove_analog_hardware(eval "$sensor#{pin}")
    end
    (5..digital_count).each do |pin|
      board.remove_digital_hardware(eval "$digital#{pin}")
    end
  end
end

