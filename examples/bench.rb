#
# This is a simple example to blink an led
# every half a second
#

require File.expand_path('../../lib/dino', __FILE__)

board = Dino::Board.new(Dino::TxRx::Serial.new)

# Keep a led blinking.
led = Dino::Components::Led.new(pin: '13', board: board)
led_thread = Thread.new do
  [:on, :off].cycle do |switch|
    led.send(switch)
    sleep 0.5
  end
end

# Keep a servo moving.
servo = Dino::Components::Servo.new(pin: 9, board: board)
servo_thread = Thread.new do
  [0, 90].cycle do |pos|
    servo.position = pos
    sleep 0.3
  end
end

# Keep a servo moving.
servo2 = Dino::Components::Servo.new(pin: 10, board: board)
servo_thread2 = Thread.new do
  [0, 90].cycle do |pos|
    servo2.position = pos
    sleep 0.5
  end
end

# Keep a servo moving.
servo3 = Dino::Components::Servo.new(pin: 11, board: board)
servo_thread3 = Thread.new do
  [0, 90].cycle do |pos|
    servo3.position = pos
    sleep 0.5
  end
end



$counter_analog = 0
counter_digital = 0
test_time = 5

puts "Starting tests..."

# Ranges of digital and analog pin numbers to read.
digital_range = 2..5
analog_range = 0..5

digital_range.each do |digital_max|
  analog_range.each do |analog_max|

    # Define ranges for this test test.
    digital_test_range = digital_range.min..digital_max
    analog_test_range = analog_range.min..analog_max

    # Setup hardware
    analog_test_range.each do |pin|
      eval "$sensor#{pin} = Dino::Components::Sensor.new(pin: 'A#{pin}', board: board)"
      eval "$sensor#{pin}.when_data_received { $counter_analog = $counter_analog + 1 }"
    end
    digital_test_range.each do |pin|
      eval "$digital#{pin} = Dino::Components::Button.new(pin: '#{pin}', board: board, pullup: true)"
      eval "$digital#{pin}.up   { counter_digital = counter_digital + 1 }"
      eval "$digital#{pin}.down { counter_digital = counter_digital + 1 }"
    end

    # Pre-test measurement
    state1_digital = counter_digital
    state1_analog = $counter_analog

    # Wait
    sleep test_time

    # Post-test measurement
    state2_digital = counter_digital
    state2_analog = $counter_analog

    # Calculation
    diff_digital = state2_digital - state1_digital
    diff_analog = state2_analog - state1_analog

    # Print
    print "#{digital_test_range.count}D/#{analog_test_range.count}A Components: "
    print "#{diff_digital/(test_time * digital_test_range.count)}Hz"
    print "/"
    print "#{diff_analog/(test_time * analog_test_range.count)}Hz per component | "
    puts  "#{(diff_digital + diff_analog)/(test_time)} responses/s overall"

    # Remove hardware
    analog_test_range.each do |pin|
      board.remove_analog_hardware(eval "$sensor#{pin}")
    end
    digital_test_range.each do |pin|
      board.remove_digital_hardware(eval "$digital#{pin}")
    end
  end
end

servo_thread.kill
led_thread.kill

