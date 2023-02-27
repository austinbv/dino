//
// This file contains low-level functions to get precise (enough)
// timing required for using the Dallas/Maxim 1-Wire protocol.
// Higher level logic is handled in Ruby.
//
#include "Dino.h"
#ifdef DINO_ONE_WIRE


// CMD = 41
// Reset the OneWire bus and return a presence value only if requested.
//
void Dino::owReset(){
  byte present;
  pinMode(pin, OUTPUT);
  digitalWrite(pin, LOW);
  microDelay(500);
  pinMode(pin, INPUT);
  digitalWrite(pin, HIGH); // Essential on ESP32. Enables pullup on others.
  microDelay(80);
  present = digitalRead(pin);
  microDelay(420);
  if(val>0) coreResponse(pin, present);
}

// CMD = 42
// Read a 64-bit address and complement, echoing each address bit to the bus,
// unless we are searching a branch that has that bit set to 1, then echo 1.
//
void Dino::owSearch(){
  byte addr;
  byte comp;

  // Start streaming the message.
  stream->print(pin); stream->print(':');

  for(byte i=0; i<8; i++){
    for(byte j=0; j<8; j++){
      bitWrite(addr, j, owReadBit());
      bitWrite(comp, j, owReadBit());

      // First 8 bytes of auxMsg is a 64-bit branch mask. Any bit set to 1 says
      // that we're searching a branch with that bit set to 1, and must force
      // it to be 1 on this pass. Write 1 to both the address bit and the bus.
      //
      // We also do not change the complement bit from 0, Even though the bus
      // said 0/0, we are sending back 1/0, hiding discrepancies we are testing,
      // only sending those that appeared this time, which is what we care about.
      //
      if(bitRead(auxMsg[i], j) == 1){
        owWriteBit(1);
        bitWrite(addr, j, 1);

      // Whether there was no "1-branch" marked for this bit, or there is no
      // discrepancy at all, just echo address bit to the bus. We compare
      // addr/comp remotely to find discrepancies for future passes.
      //
      } else {
        owWriteBit(bitRead(addr, j));
      }
    }
    stream->print(addr);
    stream->print(',');
    stream->print(comp);
    stream->print((i == 7) ? '\n' : ',');
  }
}

// CMD = 43
// Write to the OneWire bus.
//
// val = number of bytes to write + parasite power condition flag in MSB.
// auxMsg[0] = first byte of data and so on...
// Limited to 127 bytes. Validate remotely.
//
void Dino::owWrite(){
  // Check and clear parasite flag.
  bool parasite = bitRead(val, 7);
  bitClear(val, 7);

  byte b;
  for(byte i=0; i<val; i++){
    b = auxMsg[i];
    for(byte j=0; j<8; j++){
      owWriteBit(bitRead(b, j));
    }
  }

  // Drive bus high to feed the parasite capacitor after writing if necessary.
  if (parasite) {
    pinMode(pin, OUTPUT);
    digitalWrite(pin, HIGH);
  }
}

void Dino::owWriteBit(byte b){
  // Write slot always starts with pulling the bus low for at least 1us.
  pinMode(pin, OUTPUT);
  digitalWrite(pin, LOW);
  microDelay(1);

  // If 1, release so the bus idles high, and wait out the 60us write slot.
  if(b == 1){
    pinMode(pin, INPUT);
    digitalWrite(pin, HIGH); // Essential on ESP32. Enables pullup on others.
    microDelay(59);
  // If 0, keep it low for the rest of the 60us write slot, then release.
  } else {
    microDelay(59);
    pinMode(pin, INPUT);
    digitalWrite(pin, HIGH); // Essential on ESP32. Enables pullup on others.
  }
  // Minimum 1us recovery time after each slot.
  microDelay(1);
}

// CMD = 44
// Read bytes from the OneWire bus.
//
// val = number of bytes to read
//
void Dino::owRead(){
  byte b;

  // Start streaming the message.
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
  // Pull low for at least 1us to start a read slot, then release.
  pinMode(pin, OUTPUT);
  digitalWrite(pin, LOW);
  microDelay(1);
  pinMode(pin, INPUT);
  digitalWrite(pin, HIGH); // Essential on ESP32. Enables pullup on others.

  // Wait for the slave to write to the bus. It should hold for up to 15us.
  microDelay(5);

  // If slave pulled the bus high, the bit is a 1, else 0.
  b = digitalRead(pin);

  // Wait out the 60us read slot + recovery time.
  microDelay(55);
  return b;
}
#endif
