//
// This file adds to the Dino class only if DINO_I2C is defined in Dino.h.
//
#include "Dino.h"
#ifdef DINO_I2C

#include <Wire.h>

bool i2cStarted = false;

// Only start the Wire class if not already started.
// Lazy initialization in case user wants to use I2C pins for something else.
void Dino::i2cBegin() {
  if (!i2cStarted) {
    Wire.begin();
    i2cStarted = true;
  }
}

// CMD = 33
// Ask each address for a single byte to see if it exists on the bus.
void Dino::i2cSearch() {
  stream->print(SDA);

  i2cBegin();
  for (uint8_t i = 0x08; i < 0x78;  i++) {
    uint8_t length = 1;
    Wire.requestFrom(i, length);
    if (Wire.available()){
      stream->print(':'); stream->print(i);
      while(Wire.available()) Wire.read();
    }
  }

  stream->print('\n');
}

// CMD = 34
// Write to an I2C device. All params as binary in auxMsg.
//
// val        = Settings
// val bit 0  = repeated start
// val bit 1  = write register address before reading
// val bit 2+ = unused
//
// auxMsg[0]  = 7-bit device address
// auxMsg[1]  = reserved
// auxMsg[2]  = data length
// auxMsg[3]+ = data
//
// Max limited by aux message size.
//
void Dino::i2cWrite() {
  byte repeatedStart = bitRead(val, 0);
  i2cBegin();
  Wire.beginTransmission(auxMsg[0]);
  Wire.write(&auxMsg[3], auxMsg[2]);
  Wire.endTransmission(repeatedStart);
}

// CMD = 35
// Read from an I2C device. All params as binary in auxMsg.
//
// val        = Settings
// val bit 0  = repeated start
// val bit 1  = write register address before reading
// val bit 2+ = unused
// 
// auxMsg[0]  = 7-bit device address
// auxMsg[1]  = reserved
// auxMsg[2]  = register address
// auxMsg[3]  = number of bytes
//
// Max 32 bytes, limited by Wire library buffer. Validate remotely.
//
void Dino::i2cRead() {
  if (auxMsg[3] > 32) auxMsg[3] = 32;
  byte repeatedStart = bitRead(val, 0);
  i2cBegin();

  // Optionally write a register address before reading.
  if (bitRead(val, 1)) {
    Wire.beginTransmission(auxMsg[0]);
    Wire.write(auxMsg[2]);
    Wire.endTransmission(repeatedStart);
  }
  Wire.beginTransmission(auxMsg[0]);
  Wire.requestFrom(auxMsg[0], auxMsg[3], repeatedStart);

  // Send data as if coming from SDA pin. Prefix with device adddress.
  // Fail silently if no bytes read / invalid device address.
  if(Wire.available()){
    stream->print(SDA); stream->print(':');
    stream->print(auxMsg[0]); stream->print('-');
  }
  uint8_t currentByte = 0;
  while(Wire.available()){
    currentByte++;
    stream->print(Wire.read());
    stream->print((currentByte == auxMsg[3]) ? '\n' : ',');
  }
  Wire.endTransmission(repeatedStart);
}
#endif
