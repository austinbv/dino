# Dino 0.13.0 [![Test Status](https://github.com/austinbv/dino/actions/workflows/ruby.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/ruby.yml)
### Ruby Meets Microcontrollers
Dino gives you a high-level Ruby interface to low-level hardware, without writing microcontroller code. Use LEDs, buttons, sensors and more, just as easily as any Ruby object:

````ruby
led.blink 0.5

lcd.print "Hello World!"

reading = sensor.read

button.down do
  puts "Button pressed!"
end
````

Dino doesn't run Ruby on the microcontroller (see the [mruby-dino](#mruby) project). It runs a C++ firmware that exposes as much low-level I/O as possible, so we can use it in Ruby. It becomes a peripheral for your computer.

High-level abstraction in Ruby makes hardware classes easy to implement, with intuitive interfaces. They multitask a single core microcontroller, with thread-safe state, and callbacks for inputs, but no "task" priority. If you need more I/O, integration is seamless. Connect another board and instantiate it in Ruby.

Each peripheral connected to your microcontroller(s) maps to a Ruby object you can use directly. You get to think about your hardware and appplication logic, not everything in between.

### Supported Hardware

See a full list of supported mircocontroller platforms, interfaces, and peripherals [here](HARDWARE.md).

## Getting Started

**Note:** If using Ruby in WSL on Windows, you can follow the Mac/Linux instructions, but it is not recommended. Serial (COM port) forwarding isn't currently working on WSL2, which would make it impossible to communicate with the microcontroller. There are workarounds, and you might get it working by switching to WSL1, but the [RubyInstaller for Windows](https://rubyinstaller.org/) and Arduino IDE are recommended instead.

#### 1) Install the Gem
```shell
gem install dino
```

Before using the microcontroller in Ruby, we need to flash it with the dino firmware (or "sketch" in Arduino lingo). This is needed **once** for each board, but future dino versions may need reflashing to add functionality.

#### 2) Install the Arduino IDE OR CLI

Get the Arduino IDE [here](http://arduino.cc/en/Main/Software) for a graphical interface (recommended for Windows), or use the command line interface from [here](https://github.com/arduino/arduino-cli/releases), or Homebrew.

**CLI Installation with Homebrew on Mac or Linux:**
````shell
brew update
brew install arduino-cli
````

#### 3) Install Arduino Dependencies
Dino uses Arduino cores, which add support for microcontrollers, and a few libraries. Install only the ones for your microcontroller, or install everything. There are no conflcits. Instructions for supported microcontrollers:
  * [Install Dependencies in IDE](DEPS_IDE.md) 
  * [Install Dependencies in CLI](DEPS_CLI.md) 

#### 4) Generate the Arduino Sketch
The `dino` command is included with the gem. It will make the Arduino sketch folder for you, and configure it.

**For ATmega boards, Serial over USB:** (Arduino Uno, Nano, Mega, Leonardo, Micro)
```shell
dino sketch serial
````

**For ESP8266, Serial over USB:**
```shell
dino sketch serial --target esp8266
````

**For ESP8266 or ESP32 over WiFi (2.4Ghz and DHCP Only):**
```shell
dino sketch wifi --target esp8266 --ssid YOUR_SSID --password YOUR_PASSWORD
dino sketch wifi --target esp32 --ssid YOUR_SSID --password YOUR_PASSWORD
````
**Note:** [This example](examples/connection/tcp.rb) shows how to connect to a board with a TCP socket, but the WiFi & Ethernet sketches fall back to the serial interface when no TCP client is connected.

#### 5a) IDE Flashing

* Connect the board to your computer with a USB cable.
* Open the .ino file inside your sketch folder with the IDE.
* Open the dropdown menu at the top of the IDE window, and select your board.
* Press the Upload :arrow_right: button. This will compile the sketch, and flash it to the board.

**Troubleshooting:**
* If your serial port is in the list, but the board is wrong, select the serial port anyway, then you will be asked to manually select a board.
* If your board doesn't show up at all, make sure it is connected properly. Try disconnecting and reconnecting, use a different USB port or cable, or press the reset button after plugging it in.

#### 5b) CLI Flashing

* The path output by `dino sketch` earlier is your sketch folder. Keep it handy.
* Connect the board to your computer with a USB cable.
* Check if the CLI recognizes it:

````shell
arduino-cli board list
````
  
* Using the Port and FQBN (Fully Qualified Board Name) shown, compile and upload the sketch:
````shell
arduino-cli compile -b YOUR_FQBN YOUR_SKETCH_FOLDER
arduino-cli upload -v -p YOUR_PORT -b YOUR_FQBN YOUR_SKETCH_FOLDER
````

**Troubleshooting:**
* Follow the same steps as the IDE method above. List all FQBNs using:
````shell
arduino-cli board listall
````

#### 6)  Test It

Most boards have a regular LED on-board. Test it with the [blink](examples/led/builtin_blink.rb) example. If you have an on-board WS2812 LED, use the [WS2812 blink](examples/led/ws2812_builtin_blink.rb) example instead. If it starts blinking, you're ready for Ruby!

## Examples and Tutorials

#### Tutorial

* [Here](tutorial) you will find a beginner-friendly tutorial, that goes through the basics, using commented examples and diagrams. Read the comments and try modifying the code. You will need the following:
  * 1 compatible microcontroller (see [supported hardware](HARDWARE.md))
  * 1 button or momentary switch
  * 1 potentiometer (any value)
  * 1 external RGB LED (4 legs common cathode, not a Neopixel or individually addressable)
  * 1 external LED (any color, or use one color from the RGB LED)
  * Current limiting resistors for LEDs
  * Breadboard
  * Jumper wires
  
  **Tip:** Kits are a cost-effective way to get started. They will almost certainly include these parts, plus more, getting you well beyond the tutorial.

#### Included Examples

* The [examples](examples) folder contains at least one example per supported peripheral, demonstrating its interface, and a few that use multiple peripherals together.
* Each example should incldue a wiring diagram alongside its code (still incomplete).

####  More Examples

* Try [Getting Started with Arduino and Dino](http://tutorials.jumpstartlab.com/projects/arduino/introducing_arduino.html) from [Jumpstart Lab](http://jumpstartlab.com) (_ignore old install instructions_).
* An example [rails app](https://github.com/austinbv/dino_rails_example)  using Dino and Pusher.
* For a Sinatra example, look at the [site](https://github.com/austinbv/dino_cannon) used to shoot the cannon at RubyConf2012.

## Explanatory Talks

* "Arduino the Ruby Way" at RubyConf 2012
  * [Video by ConFreaks](https://www.youtube.com/watch?v=oUIor6GK-qA)
  * [Slides on SpeakerDeck](https://speakerdeck.com/austinbv/arduino-the-ruby-way)
  
## mruby Port

A single-board computer plus microcontroller can be a great standalone solution, especially if your project needs the computer anyway. For example, a Raspberry Pi Zero and Arduino Nano combo, running CRuby, Dino and other software.

But what if you want to be _really_ small? Building on the [mruby-esp32](https://github.com/mruby-esp32/mruby-esp32) project, Dino is being ported to run directly on the ESP32 here: [mruby-dino-template](https://github.com/dino-rb/mruby-dino-template).

## dino-piboard

There's an add-on for this gem, [dino-piboard](https://github.com/dino-rb/dino-piboard), in early development, which adds support for the Raspberry Pi's built in GPIO interface as a class-compatible "board". This allows you to connect peripherals directly to the Pi, without a microcontroller, and use the dino peripherals classes as-is.
