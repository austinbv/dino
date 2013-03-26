#c
# This is a simple example to blink an led
# every half a second
#

require File.expand_path('../../lib/dino', __FILE__)
# txrx = Dino::TxRx.new
# txrx = Dino::TxRx::TCP.new("192.168.0.77")
# txrx = Dino::TxRx::TCP.new("192.168.0.143", 3001) # ; txrx.io; sleep 5
# board = Dino::Board.new(txrx)

# txrx.write("!9800010.")



board = Dino::Board.new(Dino::TxRx::Serial.new) #(device: "/dev/tty.usbserial-A9015AK7"))
servo = Dino::Components::Servo.new(pin: 9, board: board)
led = Dino::Components::Led.new(pin: '13', board: board)

# board.heart_rate = 10
# board.analog_divider = 8

counter_analog = 0
counter_digital = 0
test_time = 2

analog_count = 5
digital_count = 6

# led.pulse(0, 128)

# Setup hardware
(0..5).each do |pin|
  eval "$sensor#{pin} = Dino::Components::Sensor.new(pin: 'A#{pin}', board: board)"
  eval "$sensor#{pin}.when_data_received { counter_analog = counter_analog + 1 }"
end
(5..9).each do |pin|
  eval "$digital#{pin} = Dino::Components::Button.new(pin: '#{pin}', board: board, pullup: true)"
  eval "$digital#{pin}.up   { counter_digital = counter_digital + 1 }"
  eval "$digital#{pin}.down { counter_digital = counter_digital + 1 }"
end




puts "Starting test..."
start_time = Time.now

loop do

  40.times do
    led.off
    led.on
  end

  # [0, 90].each do |pos|
  #   servo.position = pos
  # end

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
  print "#{digital_count -1}D/#{analog_count + 1}A Components: "
  print  "#{diff_digital/(test_time * (digital_count - 1))}Hz"
  print "/"
  print  "#{diff_analog/(test_time * (analog_count + 1))}Hz per component | "
  puts  "#{(diff_digital + diff_analog)/(test_time)} responses/s overall"

  print "Elapsed time: "
  puts Time.now - start_time

end

# Remove hardware
(0..5).each do |pin|
  board.remove_analog_hardware(eval "$sensor#{pin}")
end
(5..10).each do |pin|
  board.remove_digital_hardware(eval "$digital#{pin}")
end
