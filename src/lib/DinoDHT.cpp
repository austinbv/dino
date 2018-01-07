//
// This file adds to the Dino class only if DINO_DHT is defined in Dino.h.
// Should not be included in sketch for Arduino Due yet.
//
#include "Dino.h"
#ifdef DINO_DHT

// Include dtostrf for ARM.
#if defined(__SAM3X8E__)
  #include <avr/dtostrf.h>
#endif

// Include the DHT library and create an instance.
#include "DHT.h"
DHT dht;

// CMD = 13
// Read a DHT sensor
void Dino::dhtRead() {
  // if (pin != dht.pin)
  dht.setup(pin);
  float reading;
  char readingBuff[10];
  char prefix;
  if (val == 0) {
    reading = dht.getTemperature();
    prefix = 'T';
  } else {
    reading = dht.getHumidity();
    prefix = 'H';
  }
  if (! isnan(reading)) {
    dtostrf(reading, 6, 4, readingBuff);
    sprintf(response, "%d:%c%s", pin, prefix, readingBuff);
  }

  #ifdef debug
    Serial.print("Called Dino::dhtRead()\n");
  #endif
}

#endif
