# Welcome to Dino
[![Build Status](https://secure.travis-ci.org/austinbv/dino.png)](http://travis-ci.org/austinbv/dino)

## Get Started In No Time

Dino was designed to help you start working with your Arduino in minutes.

#### Install the Gem

```
gem install dino
```

#### Upload the Bootstrapper

* Generate the Arduino files using the included command line tool:
````
dino generate-sketches
````
* Open [the normal Arduino IDE](http://arduino.cc/en/Main/Software)
* Open the sketch you want to upload in the Arduino IDE. Use `du.ino` if you want to talk to the Arduino via USB or Serial. Use `du_ethernet.ino` for the Ethernet shield.
* Plug in your Arduino via USB.
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
