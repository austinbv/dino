//
// This file adds to the Dino class only if DINO_ONE_WIRE is defined in Dino.h.
//
#include "Dino.h"
#ifdef DINO_ONE_WIRE

#include "OneWire.h"

// CMD = 15
void Dino::ds18Read() {
  OneWire ds(pin);

  byte data[12];
  byte addr[8];

  if ( !ds.search(addr)) {
    ds.reset_search();
    return;
   }

  if ( OneWire::crc8( addr, 7) != addr[7]) {
    // Serial.println("CRC is not valid!");
    return;
  }

  if ( addr[0] != 0x10 && addr[0] != 0x28) {
    // Serial.print("Device is not recognized");
    return;
  }

  ds.reset();
  ds.select(addr);
  ds.write(0x44,1); // start conversion, with parasite power on at the end

  byte present = ds.reset();
  ds.select(addr);
  ds.write(0xBE); // Read Scratchpad

  for (int i = 0; i < 9; i++) { // we need 9 bytes
    data[i] = ds.read();
  }

  ds.reset_search();

  byte MSB = data[1];
  byte LSB = data[0];

  float tempRead = ((MSB << 8) | LSB); //using two's compliment
  float reading = tempRead / 16;
  char readingBuff[10];

  if (! isnan(reading)) {
    stream->print(pin);
    stream->print(':');
    stream->print(reading, 4);
    stream->print('\n');
  }
}

#endif
