# Changelog

## 0.11.2

* Make servos work better by using the existing Arduino Servo library.
  * Up to 12 servos can be controlled.
  * On MEGA boards, servos may be used on pins 22-33 ONLY.
  * On other boards, servos may be used on pins 2-13 ONLY.
  * Flashing the updated sketch to the board is required.

## 0.11.1
 
### New Features

* Support for the Arduino Ethernet shield and compatibles (Wiznet W5100 chipset).

* Added a `dino` command-line tool for generating and customizing the different Arduino sketches.

* Instead of reading the value of a pin by repeatedly sending messages to ask for its value, we can now set up "listeners". We tell the board which pin we'd like to listen to, and it will periodically send us the pin's value.
  * By default, digital listeners are polled every ~4ms (~250Hz).
  * Analog listeners are on a 4x divider, so they update every ~16ms (~63Hz).
  * These can be changed with the `Board#heart_rate=` and `Board#analog_divider=` methods respectively.
  * Digital listeners only send a message if the value has changed since the last check.
  * Analog listeners always  send a message.
  * Digital listeners can be set up on any pin, including analog pins. Analog listeners should only be set up on analog pins.

* Registering a listener is now the default for read components such as `Sensor` and `Button`. No changes need to be made for existing or future components. Anything using `Board#add_analog_hardware` or `Board#add_digital_hardware` will set up a listener.

  __NOTE__: Because of these changes, you'll need to upload the newest version of the sketch to your board for this version of the gem to work properly.

* Support for all 70 pins on the Arduino Mega boards.

* Built-in pullup resistors on the Arduino are now configurable in Ruby. Disabled by default.

* Support up to COM9 on Windows.

* Connect to a specific serial device by setting `device:` in the options hash when calling `Dino::TxRx::Serial.new`.

* Baud rate for serial connections is now configurable. Use the `--baud XXXXXX` option for `dino` to set the rate before uploading the sketch. Set `baud: XXXXXX` in the options hash for Dino::TxRx::Serial.new` to set the rate when connecting. Both values need to match.

* Added color methods to `RgbLed` for cyan, yellow, magenta, white and off.

### Major Changes

* All Arduino code that interacts with components has been extracted into an Arduino library. The sketches now only handle communication between a `Dino::TxRx::` class in Ruby and this library. Writing new sketches for arbitray protocols should be simpler.

* Arduino-level debug messages now use preprocessor directives instead of `if(debug)` statements. The performance and memory usage of sketches with debugging disabled is improved.

* As a result, enabling and disabling Arduino-level debug messages can no longer be done in Ruby. You'll need to enable debug messages before uploading a sketch by using the `--debug` option when generating the sketch with `dino`.

* Removed `TxRx::Telnet`. `TxRx::TCP`, written for the Ethernet shield, works even better for ser2net.

### Minor Changes

* Handshake protocol: The first command sent to the Arduino resets the board to defaults. It acknowledges and responds with the raw pin number of its first analog pin, 'A0' (pin 14 on an UNO).

* When sending messages between Ruby and the Arduino, all pins are now referenced by this numerical syntax. The value received in the handshake is used by `Dino::Board` to calculate values on the fly, so the more friendly 'A0' syntax may be used everywhere else in Ruby. This was done mostly to replace some complicated Arduino code and support > 10 analog pins.

* The Arduino's read and write operations no longer implicitly set the mode of a pin. Calling `board#set_pin_mode` when initializing a component is now required. `board#add_analog_hardware` or `board#add_digital_hardware` for read components will take care of this as well.

* The syntax of the messages sent from the Arduino to Ruby has changed slightly from "PP::VVVV\r\n" to "PP:VVVV\n" where PP and VVVV represent the pin and value respectively. The increase in (serial) throughput is usable when many analog listeners are set or polling at high rates.

* Sensors accept blocks instead of procs now.

### Fixes

* `Board#set_pin_mode` works correctly now. Input and output were swapped previously and this error was being hidden by the implicit operations mentioned above.
