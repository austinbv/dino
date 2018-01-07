//
// This file adds to the Dino class only if DINO_DHT is defined in Dino.h.
// Should not be included in sketch for Arduino Due yet.
//
#include "Dino.h"
#ifdef DINO_DHT

// Include the DHT library and create an instance.
#include "DHT.h"
DHT dht;

// CMD = 13
// Read a DHT sensor
void Dino::dhtRead() {
  // Can't access pin to check this in latest DHT library.
  // Assuming safe to repeatedly call setup for now.
  // if (pin != dht.pin)
  dht.setup(pin);

  // Always read both values
  float temperature = dht.getTemperature();
  float humidity = dht.getHumidity();

  stream->print(pin); stream->print(':');
  // Send the values as a comma delimited printed decimals with 1dp precision.
  stream->print(temperature, 1); stream->print(',');
  stream->print(humidity, 1);
  stream->print('\n');

  #ifdef debug
    Serial.print("Called Dino::dhtRead()\n");
  #endif
}

#endif
