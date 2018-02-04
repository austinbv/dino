//
// This file contains low-level functions to get precise (enough)
// timing required for using the Dallas/Maxim 1-Wire protocol.
// Higher level logic is handled in Ruby.
//
#include "Dino.h"
#ifdef DINO_ONE_WIRE

void Dino::owReset(){
  // bool present;
  pinMode(pin, OUTPUT);
  digitalWrite(pin, LOW);
  delayMicroseconds(500);
  pinMode(pin, INPUT);
  delayMicroseconds(80);
  // present = !digitalRead(pin);
  delayMicroseconds(420);
  // send presence value here
}

void Dino::owSearch(){
}

// CMD = 43
// Write to the OneWire bus.
//
// val = number of bytes to write + parasite power condition OR-ed into MSB.
// auxMsg[0] = first byte of data and so on...
// Limited to 127 bytes. Validate on remote end.
//
void Dino::owWrite(){
  bool parasite = bitRead(val, 7);
  bitClear(val, 7);

  byte b;
  for(byte i=0; i<val; i++){
    b = auxMsg[i];
    for(byte j=0; j<8; j++){
      owWriteBit(bitRead(b, j));
    }
  }

  if (parasite) {
    pinMode(pin, OUTPUT);
    digitalWrite(pin, HIGH);
  }
}

void Dino::owWriteBit(byte b){
  // Write slot always starts with pulling the bus low for at least 1us.
  pinMode(pin, OUTPUT);
  digitalWrite(pin, LOW);
  delayMicroseconds(1);

  // If 1, release so the bus idles high, and wait out the 60us write slot.
  if(b == 1){
    pinMode(pin, INPUT);
    delayMicroseconds(59);
  // If 0, keep it low for the rest of the 60us write slot, then release.
  } else {
    delayMicroseconds(59);
    pinMode(pin, INPUT);
  }
  // Minimum 1us recovery time after each slot.
  delayMicroseconds(1);
}

// CMD = 44
// Read bytes from the OneWire bus.
//
// val = number of bytes to read
void Dino::owRead(){
  byte b;
  // Start with the pin that the bus is on and the colon.
  stream->print(pin); stream->print(':');

  // Print each byte read, followed by a comma, or newline for last byte.
  for(byte i=0; i<val; i++){
    for(byte j=0; j<8; j++){
      bitWrite(b, j, owReadBit());
    }
    stream->print(b);
    stream->print((i == (val-1)) ? '\n' : ',');
  }
}

byte Dino::owReadBit(){
  byte b;
  // Pull low for at least 1us to start a read time slot, then release.
  pinMode(pin, OUTPUT);
  digitalWrite(pin, LOW);
  delayMicroseconds(1);
  pinMode(pin, INPUT);

  // Wait for the slave to write to the bus. It should hold for up to 15us.
  delayMicroseconds(5);

  // If slave pulled the bus high, the bit a 1, else 0.
  b = digitalRead(pin);

  // Wait out the 60us window + recovery time.
  delayMicroseconds(55);
  return b;
}
#endif
