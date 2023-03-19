# Dino 0.13.0 [![Test Status](https://github.com/austinbv/dino/actions/workflows/ruby.yml/badge.svg)](https://github.com/austinbv/dino/actions/workflows/ruby.yml)
### Ruby Meets Microcontrollers
Dino gives you a high-level Ruby interface to low-level hardware, without writing microcontroller code. Use LEDs, buttons, sensors and more, just as easily as any Ruby object:

````ruby
led.blink 0.5

lcd.puts "Hello World!"

reading = sensor.read

button.down do
  puts "Button pressed!"
end
````

Dino doesn't run Ruby on the microcontroller (see the [mruby-dino](#mruby) project). It runs a C++ firmware that exposes as much low-level I/O as possible, so we can use it in Ruby. It becomes a peripheral for your computer.

High-level abstraction in Ruby makes hardware classes easy to implement, with intuitive interfaces. They multitask a single core microcontroller, with thread-safe state, and callbacks for inputs, but no "task" priority. If you need more I/O, integration is seamless. Connect another board and instantiate it in Ruby.

Each physical component connected to your board(s) maps to a Ruby object you can use directly. You get to think about your hardware and appplication logic, not everything in between.

### Supported Hardware

See a full list of supported mircocontroller platforms, interfaces, and components [here](HARDWARE.md).

## Getting Started
#### 1) Install the Gem
```shell
gem install dino
```

Before using the microcontroller in Ruby, we need to flash it with the dino firmware (or "sketch" in Arduino lingo). This is needed **only once** for each board, but future dino versions may need reflashing for firmware functions.

#### 2) Install the Arduino IDE OR CLI

Get the Arduino IDE [here](http://arduino.cc/en/Main/Software) for a graphical interface, or use the command line interface from [here](https://github.com/arduino/arduino-cli/releases), or Homebrew.

**CLI Installation with Homebrew on Mac, Linux, or WSL on Windows:**
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
**Note:** [This example](examples/tcp.rb) shows how to connect to a board with a TCP socket, but the WiFi & Ethernet sketches fall back to the serial interface when no TCP client is connected.

#### 5a) IDE Flashing

* Connect the board to your computer with a USB cable.
* Open the .ino file inside your sketch folder with the IDE.
* Open the dropdown menu at the top of the IDE window, and select your board.
* Press the Upload :arrow_right: button. This will compile the sketch, and flash it to the board.

**Troubleshooting:**
* If your serial port is in the list, but the board is wrong, select the serial port anyway, then go to Tools > Board in the menus and choose your board from the list.
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

#### 6)  Test It!

Most boards have an on-board LED. It's internally connected to pin 13 on Arduinos, but might be different for you. Run the LED example [here](examples/01-led/led.rb). Change the pin number if needed. If the LED starts blinking, you're ready for Ruby!

## Examples and Tutorials

#### Included Examples

* The first 5 [examples](examples) are sort of a mini-tutorial, to familiarize you with the basics. Read the comments and try modifying the code. You will need the following:
  * 1 microcontroller (Arduino Uno, Leonardo and Mega are most compatible)
  * 1 button or momentary switch
  * 1 potentiometer (any value)
  * 1 external RGB LED (4 legs common cathode, not a Neopixel or individually addressable)
  * 1 external LED (any color, or use one color of the RGB LED)
  * Current limiting resistors for the LEDs
  * Breadboard
  * Jumper wires
  
  **Tip:** Arduino kits are a cost-effective way to get started. They will almost certainly include these parts, plus more, getting you well beyond the starter examples.
  
* The remaining examples will usually demonstrate the interface for a specific component class, or how to use multiple components together.
* Each example folder should incldue a wiring diagram alongside its code.

####  More Examples

* Try [Getting Started with Arduino and Dino](http://tutorials.jumpstartlab.com/projects/arduino/introducing_arduino.html) from [Jumpstart Lab](http://jumpstartlab.com) (_ignore old install instructions_).
* An example [rails app](https://github.com/austinbv/dino_rails_example)  using Dino and Pusher.
* For a Sinatra example, look at the [site](https://github.com/austinbv/dino_cannon) used to shoot the cannon at RubyConf2012.

## Explanatory Talks

* "Arduino the Ruby Way" at RubyConf 2012
  * [Video by ConFreaks](https://www.youtube.com/watch?v=oUIor6GK-qA)
  * [Slides on SpeakerDeck](https://speakerdeck.com/austinbv/arduino-the-ruby-way)
  
## mruby

A single board computer with a microcontroller can be a great standalone solution, especially if your project needs the computer anyway. For example, a Raspberry Pi Zero and Arduino Nano combo, running CRuby, Dino and other software.

But what if you want to be _really_ small? That's where [mruby](https://github.com/mruby/mruby) comes in. Building on the [mruby-esp32](https://github.com/mruby-esp32/mruby-esp32) project, which has mruby running on the ESP32 chip, Dino is being ported to run directly on the ESP32 here: [mruby-dino-template](https://github.com/dino-rb/mruby-dino-template).
