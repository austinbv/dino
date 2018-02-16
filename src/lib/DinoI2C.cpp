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
  for (byte i = 0x08; i < 0x78;  i++) {
    Wire.requestFrom(i, 1);
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
// val        = repeated starts?
// auxMsg[0]  = device address
// auxMsg[1]  = number of bytes
// auxMsg[2]+ = data
//
// Max 256 bytes. Validate remotely.
//
void Dino::i2cWrite() {
  i2cBegin();
  Wire.beginTransmission(auxMsg[0]);
  Wire.write(&auxMsg[2], auxMsg[1]);
  Wire.endTransmission(val);
}

// CMD = 35
// Read from an I2C device. All params as binary in auxMsg.
//
// val        = repeated starts?
// auxMsg[0]  = device address
// auxMsg[1]  = start register address
// auxMsg[2]  = number of bytes
//
// Max 32 bytes, limited by Wire library buffer. Validate remotely.
//
void Dino::i2cRead() {
  if (auxMsg[2] > 32) auxMsg[2] = 32;

  i2cBegin();
  Wire.beginTransmission(auxMsg[0]);
  Wire.write(auxMsg[1]);
  Wire.endTransmission(val); // Add repeated start option here.
  Wire.requestFrom(auxMsg[0], auxMsg[2], val);

  // Send data as if coming from SDA pin. Implement a bus lock remotely.
  // Fail silently if no bytes read / invalid device address.
  if(Wire.available()){
    stream->print(SDA); stream->print(':');
  }
  uint8_t currentByte = 0;
  while(Wire.available()){
    currentByte++;
    stream->print(Wire.read());
    stream->print((currentByte == auxMsg[2]) ? '\n' : ',');
  }
}
#endif
