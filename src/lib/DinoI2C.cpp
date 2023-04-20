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

  // Address ranges 0..7 and 120..127 are reserved.
  // Try each address in 8..119 (0x08 to 0x77).
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
// val        = Settings
// val bit 0  = repeated start
// val bit 1+ = unused
//
// auxMsg[0]  = 7-bit device addresses
// auxMsg[1]  = reserved
// auxMsg[2]  = write length lower byte
// auxMsg[3]  = write length upper byte
// auxMsg[4]+ = data
//
// Maximum write length limited by auxMsg size, or uint16_t.
//
void Dino::i2cWrite() {
  // No repeated start on ESP32.
  #if defined(ESP32)
    bool sendStop = true;
  #else
    bool sendStop = bitRead(val, 0);
  #endif
  
  // Write length is uint16 packed in auxMsg[2..3].
  uint16_t totalBytes = *reinterpret_cast<uint16_t*>(auxMsg + 2);

  // I2C library only writes in 32 byte chunks. Track remaining bytes after each chunk.
  uint16_t remainingBytes = totalBytes;

  while (remainingBytes > 0) {
    // If > 32 remaining, only write 32, else write all remaining.
    uint8_t bytesToWrite = (remainingBytes > 32) ? 32 : remainingBytes;

    // Begin
    i2cBegin();
    Wire.beginTransmission(auxMsg[0]);

    // Start or resume writing from the correct position + offset in auxMsg.
    uint16_t writeStart = totalBytes - remainingBytes + 4;
    Wire.write(&auxMsg[writeStart], bytesToWrite);

    // End, writing bytes from I2C buffer to bus.
    Wire.endTransmission(sendStop);

    // Update remaining bytes.
    remainingBytes = remainingBytes - bytesToWrite;
  }
}

// CMD = 35
// Read from an I2C device over a harwdare I2C interface.
//
// val        = Settings
// val bit 0  = repeated start
// val bit 1  = write register address before reading
// val bit 2+ = unused
// 
// auxMsg[0]  = 7-bit device address
// auxMsg[1]  = reserved
// auxMsg[2]  = read length lower byte
// auxMsg[3]  = read length upper byte
// auxMsg[4]  = register address
//
// Maximum read length limited by uint16_t.
//
void Dino::i2cRead() {
  // No repeated start on ESP32.
  #if defined(ESP32)
    bool sendStop = true;
  #else
    bool sendStop = bitRead(val, 0);
  #endif

  // Read length is uint16 packed in auxMsg[2..3].
  uint16_t totalBytes = *reinterpret_cast<uint16_t*>(auxMsg + 2);

  // I2C library only reads in 32 byte chunks. Track remaining bytes after each chunk.
  uint16_t remainingBytes = totalBytes;

  while (remainingBytes > 0) {
    // If > 32 remaining, only read 32, else read all remaining.
    uint8_t bytesToRead = (remainingBytes > 32) ? 32 : remainingBytes;

    // Ensure I2C is started.
    i2cBegin();

    // If on first pass, write register address first if needed.
    if ((totalBytes == remainingBytes) && (bitRead(val, 1))) {
      Wire.beginTransmission(auxMsg[0]);
      Wire.write(auxMsg[4]);
      Wire.endTransmission(sendStop);
    }

    // Read bytes from device.
    Wire.beginTransmission(auxMsg[0]);
    #if defined(ESP32)
      // ESP32 crashes if requestFrom gets the 3rd arg.
      Wire.requestFrom(auxMsg[0], bytesToRead);
    #else
      Wire.requestFrom(auxMsg[0], bytesToRead, sendStop);
    #endif

    // End transmission. Bytes still in Wire buffer.
    Wire.endTransmission(sendStop);

    // If on first pass, send the message prefix.
    if ((totalBytes == remainingBytes) && (Wire.available())) {
      stream->print(SDA); stream->print(':');
      stream->print(auxMsg[0]); stream->print('-');
    }

    // Send read bytes, comma delimited.
    while (Wire.available()) {
      stream->print(Wire.read());
      stream->print(',');
    }

    // Update remaining bytes.
    remainingBytes = remainingBytes - bytesToRead;

    // Terminate the message. Don't care about traling comma since Ruby ignores it.
    if (remainingBytes == 0) stream->print('\n');
  }
}
#endif
