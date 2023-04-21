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
  byte error;
  uint8_t addr;
  i2cBegin();
  stream->print(SDA);

  // Only addresses from 0x08 to 0x77 are usable (8 to 127).
  for (addr = 0x08; addr < 0x78;  addr++) {
    Wire.beginTransmission(addr);
    error = Wire.endTransmission();
    if (error == 0){
      stream->print(':'); stream->print(addr);
    }
  }
  stream->print('\n');
}

// CMD = 34
// Write to an I2C device over a harwdare I2C interface.
//
// pin
//  bits 0..6 = Device address
//  bit  7    = Send stop condition. 0 = no, repeated start. 1 = yes.
//
// val
//  bits 0..4 = Data length. NOTE: maximum of 32. Anything after is ignored.
//  bits 5..7 = Reserved for bus selection in future.
//
// auxMsg[0]+ = data
//
void Dino::i2cWrite() {
  // Get parameters from message.
  uint8_t address     =  (uint8_t)pin & 0b01111111;
  uint8_t dataLength  =  (uint8_t)val & 0b00011111;

  // Limit to 32 bytes.
  if (dataLength > 32) dataLength = 32;

  i2cBegin();
  Wire.beginTransmission(address);
  Wire.write(&auxMsg[0], dataLength);

  // No repeated start on ESP32.
  #if defined(ESP32)
    Wire.endTransmission();
  #else
    uint8_t sendStop = (uint8_t)pin >> 7;
    Wire.endTransmission(sendStop);
  #endif
}

// CMD = 35
// Read from an I2C device over a harwdare I2C interface.
//
// pin
//  bits 0..6 = Device address
//  bit  7    = Send stop condition. 0 = no, repeated start. 1 = yes.
//
// val
//  bits 0..4 = Data length. NOTE: maximum of 32. Anything after is ignored.
//  bits 5..7 = Reserved for bus selection in future.
//
// auxMsg[0]  = If > 0, write a register address of that many bytes before reading.
// auxMsg[1]+ = Register address bytes in order.
//
void Dino::i2cRead() {
  // Get parameters from message.
  uint8_t address         = (uint8_t)pin & 0b01111111;
  uint8_t sendStop        = (uint8_t)pin >> 7;
  uint8_t dataLength      = (uint8_t)val & 0b00011111;

  // Limit to 32 bytes.
  if (dataLength > 32) dataLength = 32;

  i2cBegin();
  
  // Optionally write up to a 4 byte register address before reading.
  if ((auxMsg[0] > 0) && (auxMsg[0] < 5)) {
    Wire.beginTransmission(address);
    Wire.write(&auxMsg[1], auxMsg[0]);
    Wire.endTransmission(sendStop);
  }
  
  // ESP32 crashes if requestFrom gets the 3rd arg.
  #if defined(ESP32)  
    Wire.requestFrom(address, dataLength);
  #else
    Wire.requestFrom(address, dataLength, sendStop);
  #endif
  
  // Send data as if coming from SDA pin. Prefix with device adddress.
  // Fail silently if no bytes read / invalid device address.
  if(Wire.available()){
    stream->print(SDA); stream->print(':');
    stream->print(address); stream->print('-');
    while(Wire.available()){
      stream->print(Wire.read());
      stream->print(',');
    }
    stream->print('\n');
  }
  
  // No repeated start on ESP32.
  #if defined(ESP32)
    Wire.endTransmission();
  #else
    Wire.endTransmission(sendStop);
  #endif
}
#endif
