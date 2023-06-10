# Changelog

## 0.13.0

### New Features

- `Board#map`
  - Returns a hash mapping named pins (taken from the Arduino framework) to their integer GPIO values, once the board is supported. Examples: `:A0`, `:DAC0`, `:MOSI`, `:LED_BUILTIN`.
  - Pins can be given as symbols when creating peripherals. The `Board` instance converts them to integer using `Board#convert_pin`.
  - This works by having the board send an identifier string (again taken from the Arduino framework) during handshake. The identifier is cross-referenced against a directory of YAML files, loading the right map for each board.
  - This uses [`arduino-yaml-board-maps`](https://github.com/dino-rb/arduino-yaml-board-maps). See that repo for which Arduino cores / boards are supported.

### New Boards

- ESP32-S2, ESP32-S3 and ESP32-C3 variants (`--target esp32`):
  - Newer versions of the ESP32 chip with native USB support.
  - No DACs on the S3.
  - No DACs or capacitive touch on the C3.

- SAMD21 Boards, Arduino Zero (`--target samd`):

- RP2040 Based Boards, Raspberry Pi Pico (W) (`--target rp2040`):
  - WS2812 LED arrays don't work.

- Raspberry Pi SBC (not Pico) built-in GPIO support, using [`dino-piboard`](https://github.com/dino-rb/dino-piboard) extension gem:
  - Ruby needs to be running on the Pi itself.
  - Only works with CRuby. No JRuby or TruffleRuby.
  - Folllow install instructions from `dino-piboard` gem's readme.
  - `require "dino/piboard"` instead of `require "dino"`
  - Substitute `Dino::PiBoard` for `Dino::Board` as board class.
  - Not all interfaces and components from `dino` are supported yet.

### New Components

- Hardware UART support:
  - Class: `Dino::UART::Hardware`.
  - Read/write support for a board's open (not tied to a USB port) hardware UARTs. Allows interfacing with serial peripherals.
  - Initialize giving `:index` as the UART's number, according to the Arduino IDE/pinout. `Serial1` has index `1`. `Serial2` has index `2`, and so on.
  - `:baud` argument can be given when initializing, or call `UART::Hardware#start(YOUR_BAUD_RATE)`. Default is 9600.
  - No pin arguments are needed to start the UART, but peripherals must be connected properly. Refer to your board's pinout.
  - UARTs 1..3 are supported, and map to "virtual pins" 251..253, for purposes of identifying bytes read from the board.
  - The 0th UART (`Serial`) is never used, even on boards where it is not in use, and `SerialUSB` is the Dino transport.
  - `UART::Hardware#write` accepts either a String or Array of bytes to send binary data.
  - The `UART::Hardware` instance itself buffers read bytes. Complete lines can be read with `UART::Hardware#gets`.
  - Callbacks can be attached, like other input classes, to handle each batch of raw bytes as they arrive.
  - Call `UART::Hardware#stop` to disable the UART and return the pins to regular GPIO.
  - Added `Dino::Connection::BoardUART`, allowing a board's UART to be the transport for another `Board` instance. See [this example](examples/uart/board_passthrough.rb).

- ADS1118 Analog-to-Digital Converter:
  - Class: `Dino::AnalogIO::ADS1118`.
  - Connects via SPI bus. Driver written in Ruby.
  - Can be used directly by calling `ADS1118#read` with the 2 config register bytes.
  - `#read` automatically waits for conversion before reading result.
  - Implements `BoardProxy` interface, so `AnalogIO::Input` can use it in place of `Board`.
  - For each `AnalogIO::Input` subcomponent:
    - Negative pin (1 or 3) of differential pair can be set with the keyword argument `negative_pin:`
    - Gain can be set with the keyword argument `gain:`
    - Sample rate can be set with the keyword argument `sample_rate:`
    - Sample rate doesn't affect update rate. Higher sample rates oversample for a single reaidng, reducing noise.
    - `ADS1118` sets `@volts_per_bit` in the subcomponent, so exact voltages can be calculated.
    - There is no listening interface for subcomponents.
  - Built in temperature sensor can be read with `ADS1118#temperature_read`. Only 128 SPS. No polling.

- Bosch BME/BMP 280 Temperature / Pressure / Humidity Sensor:
  - Classes: `Dino::Sensor::BME280` and `Dino::Sensor::BMP280`
  - Connects via I2C bus. Driver written in Ruby.
  - All features in the datasheet are implemented, except status checking.
  - Both are mostly identical, except for BMP280 lacking humidity.
  
- HTU21D Temperature / Humidity Sensor:
  - Class: `Dino::Sensor::HTU21D`
  - Connects via I2C bus. Driver written in Ruby.
  - Most features implemented, except reading back the configuration register, and releasing the I2C bus during measurement. Since conversion times can vary, it's simpler to let the sensor hold the line until its data is ready to be read.
  - Can be read with direct methods `HTU21D#read_temperature` and `HTU21D#read_humidity`, but these do not accept block callbacks, and there is no polling.
  - For callbacks and polling use the sub-objects accessible through `HTU21D#temperature` and `HTU21D#humidity`. See examples for more info.
  
- SSD1306 OLED Display:
  - Class: `Dino::Display::SSD1306`
  - Connects via I2C bus. Driver written in Ruby.
  - By default, `SSD1306#draw` refreshes the entire frame, using horizontal addressing mode.
  - Can do partial refreshes with `SSD1306#draw(x_min, x_max, y_min, y_max)`, defining a bounding box to redraw.
  - One 6x8 font and graphic primitves, included through `Dino::Display::Canvas`.

- L298 H-Bridge Motor Driver:
  - Class: `Dino::Motor::L298`
  - Forward, reverse, idle, and brake modes implemented.
  - Speed controlled by PWM output on enable pin.

- WS2812 / WS2812B / NeoPixel RGB LED Array:
  - Class: `Dino::LED::WS2812`
  - No fancy functions yet. Just clear, set pixels, and show.

- APA102 / Dotstar RGB LED Array:
  - Class: `Dino::LED::APA102`
  - No fancy functions yet. Just clear, set pixels, show, global and per-pixel brightness control.
  - Needs its own dedicated SPI bus. Select pin is automatically set to 255 (no pin).

See new examples in the [examples](examples) folder to learn more.

### Changed Components

- Virtually every component has been renamed to bring them out of the `Dino::Components` namespace,  make naming clearer.
  - TODO: Update here with a list of renamed components.

- SPI peripherals now go through a `Dino::SPI::Bus` object:
  - Instead of giving a board directly when creating a new SPI peripheral, a bus must be created first:
    ```ruby
      board = Dino::Board.new(connection)
      bus = Dino::SPI::Bus.new(board: board)                              # board's default SPI interface
      output_register = Dino::SPI::OutputRegister.new(bus: bus, pin: 9)   # 9  is register select pin
      input_register = Dino::SPI::InputRegister.new(bus: bus, pin: 10)    # 10 is register select pin
    ```
  - For now, this always uses the default SPI device set by the Arduino framework (`SPI` or `SPI0`), but this change will allow access to multiple SPI interfaces on a single board in the future.
  - It also allows a peripheral to mutex lock the bus for atomic operations if needed.
  - When a peripheral is added to the SPI bus, callbacks are hooked (using its select pin as identifier) directly to the board.
  - `SPI::Bus` validates select pin uniquness among peripherals, per bus instance.
  - `SPI::Bus` treats a select (enable) pin of 255 as no select pin at all (won't toggle before and after transferring).
  - See the updated [SPI examples](examples/spi) to learn more.

- Shift In/Out features refactored into `SPI::BitBang` which is class-compatible with `SPI::Bus`, except for frequency.
  - See SPI changes above.

- `SPI::Peripheral` has been extracted from the various SPI Register classes.
  - This should be used for most peripherals, and the register classes used only for simple I/O expansion registers.

- `I2C::Bus` does not automatically search when initialized.

- I2C frequency now configurable:
  - `I2C::Peripheral` and it's subclasses take `:i2c_frequency` keywoard arg when instantiating. It's stored in `@i2c_frequency` and used for all reads and writes.
  - `Board#i2c_write` and `Board#i2c_read` also accept `:i2c_frequency` as a keyword arg.
  - Valid values are: `100000, 400000, 1000000, 3400000`. Defaults to `100000` at the `Board` level, when not given.
  - **Note:** This DOES NOT work if using `dino-piboard`. See the README on that gem for more info.

- Hitachi HD44780 LCD driver rewritten in Ruby:
  - New class: `Dino::Display::HD44780`
  - `#puts` changed to `#print` to better represent functionality.
  - No longer depends on the `LiquidCrystal` Arduino library, which has been removed.
  - Depends only on `Dino::DigitalIO::Output` and `#micro_delay`.
  - Old implementation in `Dino::Components::LCD` removed.
  - This solves compatibility with boards that the library didn't work on.
  - `HD44780#create_char` allows 8 custom characters to be defined in memory addresses 0-7.
  - `HD44780#write` draws the custom  (or standard) character from a given memory address.
  
- `Dino::PulseIO::PWMOutput` (previously `Dino::Components::Basic::AnalogOutput`):
  - Changed `#analog_write` to `#pwm_write`.
  - Added `#pwm_enable` and `#pwm_disable` methods.
  - `#pwm_enable` is implicit when calling `#pwm_write`. Lazy initialize PWM peripherals on the chip. Never happens if only `#digital_write` gets called.
  - `#pwm_disable` sets the pin mode to `:output` (`OUTPUT` in Arduino), disconnects and deconfigures any PWM generating peripheral.
  - On the ESP32 `#pwm_disable` releases the LEDC channel that the pin was using, so it can be reused.

- `Dino::AnalogIO::Output` (also previously `Dino::Components::Basic::AnalogOutput`):
  - Changed `#analog_write` to `#dac_write`.
  - Does not implement `#digital_write` at all. Analog values must be used instead of `board.high` or `board.low`.

- `Dino::UART::BitBang` (previously `Dino::Components::SoftwareSerial`):
  - Only inclduedo on AVR boards. Cross-platform support isn't good, and isn't necessary since almost everything has extra hardware UARTs.
  - Read functionality added. The board listens for incoming bytes and forwards them.
  - Interface matches `Dino::UART::Hardware` except for :tx and :rx pins given when initializing. See that entry in New Components above for more info.

- `Dino::TxRx` moved to `Dino::Connection`.

### Board API Changes

- `microDelay` function exposed from the board:
  - Implements a platform independent microsecond delay.
  - All calls to `delayMicroseconds()` should be replaced with this.
  - Exposed in Ruby via `CMD=99`. It takes one argument, uint_16 for delay length in microsceonds.
  - `Board#micro_delay` and `Component::#micro_delay` are defined.
  
- `dacWrite` function added to board library. `aWrite` function renamed to `pwmWrite`. Need this to avoid conflict between DAC, PWM and regular output on some chips.

- CMD numbers for some board functions changed to accomodate dacWrite:
  ````
  dacWrite       -> 4
  aread        4 -> 5
  setListener  5 -> 6
  eepromRead   6 -> 7
  eepromWrite  7 -> 8
  pulseread   11 -> 9
  servoToggle  8 -> 10
  servoWrite   9 -> 11
  ````  

- `Board#analog_write` replaced by `Board#pwm_write` and `Board#dac_write`, matching the two C functions.

- `Board#set_pin_mode` significantly changed to better manage pullups, pulldowns, `:input_output` mode, and freeing DAC and PWM peripherals for relevant chips.

- `Board#digital_write` implicitly disconnects a PWM or DAC peripheral from the pin, but does not free it. This is necessary on chips like the ATSAMD21 and ESP32 or the `#digital_write` will not work.

- `Board#analog_write` implicitly reconnects a PWM peripheral to the pin if one was previously assigned, or assigns a new one and connects it.

- `Board#analog_resolution` has been split into `Board#analog_write_resolution` and `Board#analog_read_resoluton`, defaulting to 8 and 10-bits respectively. Write resolution applies to both PWM and DACs.

- `Board#pwm_high`, `Board#dac_high` and `Board#adc_high` defined for convenience.

- I2C and SPI transfer methods on `Board` changed to avoid using the options Hash pattern. I2C uses only positional arguments, and SPI uses positional and keyword arguments. This gives a significant performance boost on lower end processors like the Raspberry Pi Zero, and reduces CPU usage in general.

- `Board#i2c_read` and `Board#i2c_write` now only accept positional arguments, with frequency and repeated_start always being last, in that order, and optional.

- `Board#spi_transfer` and `Board#spi_bb_transfer` now only accept `:spi_mode` and `:spi_frequency` keywords for the respective arguments.

- `Board#spi_listen` and `Board#spi_bb_listen` now share the same listener storage on the board. Default is 4 listeners. `shiftListeners` have been removed.

### Minor Changes

- When instantiating a component, `Board#convert_pin` is run immediately, then the converted integer for the pin (based on the board map), is saved in `@pin`, instead of whatever form was given to `#initialize`. After this, the integer is always used as-is for sending / receiving messages. This reduces CPU usage, since `Board#convert_pin` doesn't need to be called for every message.

- As a consequence of the above change, when `Board` methods are called directly, pins must always be given as integers.

- `Poller#poll` no longer defaults to a 3 second interval and will raise an error if a numeric interval is not given.

- `MultiPin` validation and proxying has changed to not use class methods. Everything is done inside `#initialize_pins` per-instance instead. This reduces the amount of `eval` and `rescue` going on, so it's easier to understand, and changes are more portable to mruby.

- Calling `#update` with `nil`, on any object using the `Callback` pattern, will prevent callbacks from being run, but still remove any one-time callbacks present in the `:read` key.

- If `#pre_callback_filter` returns nil, callbacks will also not be run, behaving just as above.

- Added [this example](examples/ws2812/ws2812_builtin_blink.rb) as a blink example for boards where :LED_BUILTIN maps to a single on-board WS2812 LED, instead of a regular LED.

- Removed `Dino::Board::ESP8266`, in favor of the new board mapping functionality. See New Features above.

- Aux message size limits changed to:
  - 512 + 16: When using IR output or WS2812 and not using ATmega168
  - 256 + 16: When not using IR output or WS2812, any board
  - 32  + 16: When all the features that use lots of aux are disabled (core sketch)

- `Dino::Connection::Serial` tries to read up to 64 bytes each time now instead of 1, reducing the number of FFI calls, and CPU usage.

- `Dino::Connection::FlowControl` simplified to always wait 1ms if no bytes to read or write. This also reduces CPU usage. This might affect the time precision of values received from listeners, but they weren't guaranteed to be evenly spaced anyway. Will add a timestamped listener feature in the future if needed.

- All `Serial.print` style debugging removed from the Arduino sketch, in favor of the new debugger in the Arduino IDE. If this style of debugging is still needed, the sketch should emit lines beginning with "DBG:". These will be caught by the Ruby parser and printed to the terminal.

- Started using `simplecov` gem to track test coverage.

### Bug Fixes

- Fixed `Dino::DigitalIO::Output` not setting its state through its mutex.

- Fixed `Piezo` functionality. Frequency and duration values weren't being properly cast on the board. Duration is also limited to 16 bits now, instead of 32, as it should be to match the Arduino function.

- Added validation for I2C writes not exceeding 32 bytes, since this is a limit of the native (AVR) library  buffer. May increase for boards with bigger buffers in the future.

- Stricter regex validation in `I2C::Bus` for identifying a series of bytes coming from a specific I2C address.

- `I2C::Bus` and `OneWire::Bus` now validate peripheral addresses as unique, per bus instance.

## 0.12.0

### New Boards
- The `dino sketch` shell command now accepts a `--target` argument. It includes/excludes features to tailor the sketch for different boards/chips. Run `dino targets` for more info.

- ATmega Based Boards (default) (`--target mega`):
  - This is the default sketch if `--target` isn't specified, and works for Arduino (and other) products based on the ATmega AVR chips, like the Uno, Nano, Leonardo and Mega.

- ESP8266 (`--target esp8266`):
  - Works with either built in WiFi or Serial.
  - WiFi version supports OTA (over-the-air) update in the Arduino IDE. Initial flash must still be done via serial.
  - Dev boards can map GPIOs to physical pins differently. Always look up the GPIO numbers and use those for pin numbers.
  - **Note:** SoftwareSerial and LiquidCrystal (LCD) both do not work on the ESP8266, and are excluded from the sketch.
  
- ESP32 (`--target esp32`):
  - Works with either built in WiFi or Serial.
  - WiFi version does NOT support OTA (over-the-air) updates yet.
  - Only tested with the original ESP32 module so far, not the later revisions with slightly different hardware.
  - Dev boards can map GPIOs to physical pins differently. Always look up the GPIO numbers and use those for pin numbers.
  - **Note:** Servos and analog outputs share the `LEDC` channels on the board. Maximum of 16 combined.
  - **Note:** SoftwareSerial and LiquidCrystal (LCD) both do not work on the ESP32, and are excluded from the sketch.
  - **Note:** SPI bug exists where input modes don't match other platforms. Eg. For a register using mode 0 on AVR, mode 2 needs to be set on ESP32 for it to work. Using mode 0 misses a bit.
  
- Arduino Due (`--target sam3x`) :
  - Up to 12-bit analog in/out. Pass a `bits:` option to `Board#new` to set resolution for both.
  - DAC support. Refer to DAC pins as `'DAC0'`, `'DAC1'`, just as labeled on the board. Call `#analog_write` or just `#write` on an `sensor` component that uses the pin.
  - Uses the native ARM serial port by default. Configurable in sketch to use programming port.
  - **Note**: SoftwareSerial, Infrared, and Tone are incompatible with the Arduino Due, and excluded from the sketch.

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
  - Components connecting to more than 1 pin, like an RGB LED or rotary encoder, are now modeled as `MultiPin` and contain multiple `SinglePin` `proxies`. An `RGBLed` is built from 3 `sensor`s, for example, one for each color, connected to a separate pin.
  - `MultiPin` implements a shortcut class method `proxy_pins`. Proxying a pin allows subcomponent pin numbers to be given as a hash when initializing an instance of a `MultiPin` component. Eg: `{red: 9, green: 10, blue: 11}` given as the `pins:` option for `RGBLed#new`.
  -  When initialized, subcomponents corresponding to the proxied pins are automatically created. They're stored in `#proxies` and `attr_reader` methods are created for each, corresponding to their key in the `pins:` hash. Eg: `RGBLed#green` and `RGBLed#proxies[:green]` both give the `sensor` component that represents the green LED inside the RGB LED, connected to pin 10.

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
