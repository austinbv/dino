# Dino 0.12.0 [![Build Status](https://secure.travis-ci.org/austinbv/dino.png)](http://travis-ci.org/austinbv/dino)
#### Ruby Meets Microcontrollers
Dino gives you a high-level Ruby interface to low-level hardware, without writing microcontroller code. Use LEDs, buttons, sensors and more, just as easily as any Ruby object:

````ruby
led.blink 0.5

lcd.puts "Hello World!"

reading = sensor.read

button.down do
  puts "Button pressed!"
end
````

Dino doesn't run Ruby on the microcontroller board either, like [mruby](https://github.com/mruby/mruby). The board always runs a C++ firmware that exposes as much low-level I/O as possible, so we can use it in Ruby. It becomes an I/O peripheral for your computer.

High-level abstraction in Ruby makes hardware classes easy to implement, with interfaces we expect. They also get thread-safe state, callbacks for inputs, and effectively mulitask a single threaded microcontroller (no "task" priority though).

Physical components connected to your boards map to Ruby objects you can use directly. You get to think about your hardware and appplication logic, not all the stuff in between.

## Getting Started
#### 1) Install the Gem
```shell
gem install dino
```

Before we can use the microcontroller in Ruby, we need to flash it with the dino firmware (or "sketch" in Arduino slang). This is needed **only once** for each board, but future versions of dino may need reflashing to add firmware-level functions.

#### 2) Install the Arduino IDE OR CLI

Download the Arduino IDE from [here](http://arduino.cc/en/Main/Software) for a graphical interface, or install the command line interface from [here](https://github.com/arduino/arduino-cli/releases), or Homebrew.

**CLI Installation with Homebrew on Mac, Linux, or WSL on Windows:**
````shell
brew update
brew install arduino-cli
````

#### 3) Install Arduino Dependencies
Dino uses Arduino "cores" which add microcontroller support, and a few C++ libraries for now. We need to install them.

**IDE:**
* Open the IDE and select Tools > Board > Board Manager from the menus.
* Search for `ESP8266 Boards` and install the latest version.
* Now go to: Tools > Manage Libraries.
* Find and install the following libraries, at the version numbers given:
  * `Liquid Crystal by Arduino, Adafruit` at latest version
  * `IRremote by shirriff, z3to, ArminJo` at `version 2.2.3`
  * `IRremoteESP82666 by David Conran, Sebastien Warin` at `version 2.3.2`

**CLI:**
````shell
arduino-cli core install esp8266:esp8266
arduino-cli lib install LiquidCrystal
arduino-cli lib install IRremote@2.2.3
arduino-cli lib install IRremoteESP8266@2.3.2 
````

#### 4) Generate the Arduino Sketch
The `dino` command is included with the gem. It will make the Arduino sketch folder for you, and configure it.

**For ATmega boards, Serial over USB:** (Arduino Uno, Nano, Mega, Leonardo, Micro)
```shell
dino sketch serial
````

**For ESP8266, Serial over USB:**
```shell
dino sketch serial -target esp8266
````

**For ESP8266 over WiFi (2.4Ghz and DHCP Only):**
```shell
dino sketch wifi -target esp8266 -ssid YOUR_SSID -password YOUR_PASSWORD
````
**Note:** [This example](https://github.com/austinbv/dino/tree/master/examples/tcp.rb) shows how to instantiate a board over the network. After flashing, you'll need to figure out what IP address your board has, and modify the TxRx line in any other example you wish to run. They are written for serial.

#### 5a) IDE Flashing

* Connect the board to your computer with a USB cable.
* Open the .ino file inside your sketch folder with the IDE.
* Open the dropdown menu at the top of the IDE window, and select your board.
* Press the Upload ➡️ button. This will compile the sketch, and flash it to the board.

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

Most boards have an on-board LED. It's internally connected to pin 13 on Arduinos, but might be another pin on your board. Run the LED example from [here](https://github.com/austinbv/dino/tree/master/examples/01-led/led.rb), changing the pin number if needed. If the LED starts blinking, you're ready for Ruby!

## Examples and Tutorials

#### Included Examples

* The first 5 [examples](https://github.com/austinbv/dino/tree/master/examples) are sort of a mini-tutorial, to familiarize you with the basics. Read the comments and try modifying the code. You will need the following:
  * 1 microcontroller (Arduino Uno, Leonardo and Mega are most compatible)
  * 1 button or momentary switch
  * 1 potentiometer (any value)
  * 1 external RGB LED (4 legs common cathode, not a Neopixel, or individually addressable)
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
