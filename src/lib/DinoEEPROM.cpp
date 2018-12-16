//
// Basic EEPROM read and write functionality.
//
#include "Dino.h"

// CMD = 6
// Read from the microcontroller's EEPROM.
//
// pin         = empty
// val         = number of bytes to read
// auxMsg[0-1] = start address
//
void Dino::eepromRead(){
  if (val > 0) {
    uint16_t startAddress = (uint16_t)auxMsg[1] << 8 | auxMsg[0];

    // Stream read bytes as if coming from a pin named 'EE'.
    stream->print("EE");
    stream->print(':');
    stream->print(startAddress);
    stream->print('-');

    for (byte i = 0;  (i < val);  i++) {
      stream->print(EEPROM.read(startAddress + i));
      stream->print((i+1 == val) ? '\n' : ',');
    }
  }
}

// CMD = 7
// Write to the microcontroller's EEPROM.
//
// pin         = empty
// val         = number of bytes to write
// auxMsg[0-1] = start address
// auxMsg[2+]  = bytes to write
//
void Dino::eepromWrite(){
  if (val > 0) {
    uint16_t startAddress = (uint16_t)auxMsg[1] << 8 | auxMsg[0];

    for (byte i = 0;  (i < val);  i++) {
      if(EEPROM.read(startAddress + i) != auxMsg[2+i]) {
        EEPROM.write(startAddress + i, auxMsg[2+i]);
      }
    }
  }
}