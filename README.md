# Dino 0.11.2
[![Build Status](https://secure.travis-ci.org/austinbv/dino.png)](http://travis-ci.org/austinbv/dino)

## Get Started In No Time

Dino lets you start programming your Arduino with Ruby in minutes.

#### Install the Gem

```shell
gem install dino
```

#### Prepare the Bootstrapper

Use the included command line tool to create a folder with the Arduino sketch you want to use and optionally configure it.

```shell
# If connecting via serial, USB or ser2net, this is all you should need:
dino generate-sketch serial

# If usng the ethernet shield, you'll want to specify unique MAC and IP addresses:
dino generate-sketch ethernet --mac XX:XX:XX:XX:XX:XX --ip XXX.XXX.XXX.XXX

# For more options:
dino help
```

__Note:__ Current Ethernet shields come with a sticker indicating the MAC address you should use with them. For older shields without a dedicated MAC address, inventing a random one should work, but don't use the same one for multiple boards. Valid IP addresses depend on the configuration of your network.

#### Upload The Bootstrapper

* Connect the Arduino to a USB port on your machine, regardless of which sketch you're using.
* Open [the normal Arduino IDE](http://arduino.cc/en/Main/Software)
* Open the `.ino` file in the sketch folder you just generated.
* Click the upload button (an arrow).

#### Verify Install

* Build the sample circuit [examples/led/led.png](https://raw.github.com/austinbv/dino/master/examples/led/led.png)
* From your terminal, execute `ruby example/led/led.rb`
* Observe your LED blinking continuously

## Examples and Tutorials

### Circuits and Programs

* Take a look in [the example directory](https://github.com/austinbv/dino/tree/master/examples) for small component examples
* Try [Getting Started with Arduino and Dino](http://tutorials.jumpstartlab.com/projects/arduino/introducing_arduino.html) from [Jumpstart Lab](http://jumpstartlab.com), building a number-guessing game and a simple nightlight
* An example [rails app using Dino and Pusher](https://github.com/austinbv/dino_rails_example)
* For a Sinatra example look at the [site used to shoot the cannon at RubyConf2012](https://github.com/austinbv/dino_cannon)

### Explanatory Talks

* "Arduino the Ruby Way" at RubyConf 2012
  * [Video by ConFreaks](http://confreaks.com/videos/1294-rubyconf2012-arduino-the-ruby-way)
  * [Slides on SpeakerDeck](https://speakerdeck.com/austinbv/arduino-the-ruby-way)
