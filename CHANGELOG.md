# Changelog

## 0.12.0

### New Boards
- The `dino sketch` shell command now accepts a `--target` argument. It includes/excludes features to tailor the sketch for different boards/chips. Run `dino targets` for more info.

- ATmega Based Boards (default) (`--target mega`):
  - This is the default sketch if `--target` isn't specified, and works for Arduino (and other) products based on the ATmega AVR chips, like the Uno, Nano, Leonardo and Mega.

- ESP8266 (`--target esp8266`):
  - Works with `Dino::Board.new`, but calling `Dino::Board::ESP8266.new` instead allows pins to be referred to as any of `'GPIO4'`, `4`, or `'D2'`, specifically for the NodeMCU dev board. When in doubt, look up your board's GPIO mapping and use those numbers instead.
  - Works with either built in WiFi or Serial.
  - WiFi version supports OTA (over-the-air) update in the Arduino IDE. Initial flash must still be done via serial.
  - **Note:** SoftwareSerial and LiquidCrystal (LCD) both do not work on the ESP8266, and are excluded from th sketch.
  
- ESP32 (`--target esp32`):
  - Works with either built in WiFi or Serial.
  - WiFi version does NOT support OTA (over-the-air) updates yet.
  - **Note:** Servos and analog outputs share the `LEDC` channels on the board. Maximum of 16 combined.
  - **Note:** SoftwareSerial and LiquidCrystal (LCD) both do not work on the ESP32, and are excluded from th sketch.
  
- Arduino Due (`--target sam3x`) :
  - Up to 12-bit analog in/out. Pass a `bits:` option to `Board#new` to set resolution for both.
  - DAC support. Refer to DAC pins as `'DAC0'`, `'DAC1'`, just as labeled on the board. Call `#analog_write` or just `#write` on an `AnalogOutput` component that uses the pin.
  - Uses the native ARM serial port by default. Configurable in sketch to use programming port.
  - **Note**: SoftwareSerial, Infrared, and Tone are currently incompatible with the Arduino Due, and excluded from the sketch.

- ATmega168 (`--target mega168`):
  - By excluding a lot of features, we can still fit the memory constraints of the ATmega168 chips found in older Arduinos.
  -  SoftwareSerial, LCD, OneWire and IROut are compatible, but left out to keep memory usage down.
  - Included libraries can be toggled in `DinoDefines.h` to suit your needs.
  - **Note:** Aux message is limited to 264 bytes on the mega168, or less depending on included libraries. The only feature currently affected by this is sending long infrared signals, like for an air conditioner.

### New Components

- `TxRx::TCP` allows communication with the board over an IP network, instead of serial connection. Tested on Arduino Uno Ethernet Shield (Wiznet W5100), and ESP8266 native WiFi. Should work on Uno WiFi shield, but is **untested**. WiFi must be configured before flashing. Instad of `dino sketch serial`, use `dino sketch wifi`.

- Hitachi HD44780 LCD support. _Uses Arduino `LiquidCrystal` library._

- Seven Segment Display support. _Ruby implementation as multiple LEDs._

- Infrared Emitter support. _Uses [Arduino-IRremote](https://github.com/z3t0/Arduino-IRremote), and the [ESP8266 fork](https://github.com/markszabo/IRremoteESP8266) where applicable._

- Tone (piezo) support. _Uses Arduino `tone`,`noTone` functions._ 

- SoftwareSerial **(write only)**. _Uses Arduino `SoftSerial` library. Only tested on ATmega chips._

- Potentiometer class, based on AnalogInput, but enables moving average smoothing by default, and adds #on_change callback method.

- Rotary encoder support. _Polls @ 1ms interval._ **WARNING**: Not suitable for high speed or precise position needs. It will definitely miss steps. Sufficient for rotary knobs as user input.

- DHT11 / DHT 21 (AM2301) / DHT22 temperature and relative humidity sensor support. _Custom implementation where input pulses are measured on the board, then decoded in Ruby._

- DS3231 RTC (real time clock) over I2C _(Ruby implementation)_

- DS18B20 temperature sensor. _Uses custom implementation of Dallas/Maxim 1-Wire bus below._

- Dallas/Maxim 1-Wire bus support. _Low level timing functions run on the board. High level logic in Ruby._
  - Most bus features are implemented: reset/presence detect, parasite power handling, bus search and slave device identification, CRC. No overdrive support.
  - Based on [Kevin Darrah's video](https://www.youtube.com/watch?v=ZKNQhzPwH0s) explaining the DS18B20 datasheet.

- I2C bus support. _Uses Arduino `Wire` library._

- Shift Register support. _Uses Arduino `ShiftOut` and `ShiftIn` functions._

- SPI bus support (_uses Arduino `SPI` library_) :
  - Read/Write Transfers
  - Read-Only Listeners (like digital/analog listeners, but reads n bytes from MISO)

- Generic input and output register classes for the above 2: `Register::ShiftIn`, `Register::ShiftOut`, `Register::SPIIn`, `Register::SPIOut`.

- Board EEPROM support. _Uses Arduino `EEPROM` library._

### Changed Components
- Servos can now be connected to arbitrary pins as long as they are supported by the board.

- Digital and analog listeners now have dividers on a per-pin basis.
  - Timing is based on a 1000 microsecond tick being counted by the board.
  - Call `#listen` with a value as the first argument. Eg. `analog_sensor.listen(64)` will tell the board to send us that specific sensor's state every 64 ticks (~64ms) or around 16 times per second, without affecting other components' rates.
  - Valid dividers are: `1, 2, 4, 8, 16, 32, 64, 128`.
  - Defaults are same as before: `4` for digital, `16` for analog.

### Hardware Abstraction

- `MultiPin` abstraction for components using more than one pin:
  - Components connecting to more than 1 pin, like an RGB LED or rotary encoder, are now modeled as `MultiPin` and contain multiple `SinglePin` `proxies`. An `RGBLed` is built from 3 `AnalogOutput`s, for example, one for each color, connected to a separate pin.
  - `MultiPin` implements a shortcut class method `proxy_pins`. Proxying a pin allows subcomponent pin numbers to be given as a hash when initializing an instance of a `MultiPin` component. Eg: `{red: 9, green: 10, blue: 11}` given as the `pins:` option for `RGBLed#new`.
  -  When initialized, subcomponents corresponding to the proxied pins are automatically created. They're stored in `#proxies` and `attr_reader` methods are created for each, corresponding to their key in the `pins:` hash. Eg: `RGBLed#green` and `RGBLed#proxies[:green]` both give the `AnalogOutput` component that represents the green LED inside the RGB LED, connected to pin 10.

- `BoardProxy` abstraction for shift/SPI registers:
  - The `Register` classes implement enough of the `Board` interface to satisfy components based on `DigitalInput` and `DigitalOutput`, such as `Led` or `Button`.
  - This lets you call methods on components directly, rather than manipulating the register data to control components indirectly. 
  - Initialize the appropriate `Register` object for the type of register. To initialize a component connected to the register, use the register as the `board:`, and give the parallel I/O pin on the register that the component is connected to. Pin 0 maps to the lowest bit.
  - This also works for `MultiPin` components built out of only `DigitalInput` or `DigitalOutput`, eg. `SSD` - seven segment display or `RGBLed`. See `examples/register` for more.

### Input Components, Callbacks and State
- `@value` has been renamed to `@state`.
  - By default, all components define `#state` and `#state=`, which access `@state` through `@state_mutex`. This way we don't try to read with `#state` while a callback is updating it with `#state=`.
  - `@state` can be any Ruby object representing the state of the component.

- Callback functionality for components has been extracted into a mixin module, `Mixins::Callbacks`.
  - Like before, callbacks for all components on a board run sequentially, in a single "update" thread, separate from the main thread. This is the same thread reading from TxRx.
  - `#add_callback` and `#remove_callback` methods are available, and take an optional `key` as argument.
  - Blocks given to `#add_callback` are stored in `@callbacks[key]`, to be called later, when the "update" thread receives data for the component. The default key is `:persistent`. 
  - Each key represents an array of callbacks, so multiple callbacks can share the same key.
  - Calling `#remove_callbacks` with a key empties that array. Calling with no key removes **all** callbacks for the component.
  - `#pre_callback_filter` is defined in the `Callbacks` module. The return value of this method is what is given to the component's callbacks and to update its `@state`. By default, it returns whatever was given from the board.
  - Override `#pre_callback_filter` to process data before giving it to callbacks and `@state`. Eg: given raw bytes from a DHT sensor, process them into a hash containing `:celsius`, `: fahrenheit` and `:humidity` values. That hash is given to to callbacks and `#update_state` instead of the original string of raw bytes.
  - `#update_state` is defined in the `Callbacks` module. It is called after all callbacks are run and given the return value of `#pre_callback_filter`. By default, it sets `@state=` to the value given.
  - Override it if updating `@state` is more complex than this, but be sure to either use `#state=` only once, or wrap the operation in `@state_mutex.synchronize`.

- Input components no longer automatically start listening when created, since there are more options for reading inputs.
  - `DigitalInput` and its subclasses are the exception to this. They automatically listen, since there is little advantage to other modes.

- Input components can have any combination of `#read`, `#poll` and `#listen` methods now, coming from `Reader`, `Poller`, and `Listener` respectively, inside `Mixins`.
  - `#read` sends a single read command by calling `#_read`, and blocks the main thread, until `data` is received from `#pre_callback_filter`. When received, any block that was given to `#read` will run once as a callback and be removed immediately. `#read` then stops blocking the main thread and returns `data`.
  - `#poll` requires an interval (in seconds) as its first argument. It starts a new thread, and keeps calling `#_read` in it, at the given interval. `#poll` does not block the main thread, and does not return a value. A block given will be added as a callback inside the `:poll` key.
  - `#listen` adds its block as a callback inside the `:listen` key, calls `#_listen` and returns immediately.
  - `#stop` stops polling **and** listening. It also **removes all callbacks** in the **`:poll` and `:listen` keys** (callbacks added as blocks when polling or listening).

### Minor Changes
- Serial communication now uses the [`rubyserial`](https://github.com/hybridgroup/rubyserial) gem instead of [`serialport`](https://github.com/hparra/ruby-serialport).
- Switched from `rspec` to `minitest` for testing.
- Added more useful information and errors during the connect & handshake process.
- Extended message syntax so the Arduino can receive arbitrary length messages, including binary.
- Created `Dino::Message` class to handle message construction.
- Moved CLI into it's own class, `Dino::CLI`.
- Added simple flow control to avoid overrunning the 64 byte input buffer in the Arduino `Serial` library. No flow control for Ruby receiving data.

## 0.11.3
* Backport bug fixes from 0.12:
  * Listeners weren't working properly on the Arduino MEGA.
  * More reliable handshake.

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
