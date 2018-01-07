//
// This file adds to the Dino class only if DINO_I2C is defined in Dino.h.
//
#include "Dino.h"
#ifdef DINO_I2C

#include "I2C.h"


// CMD = 31
// Start I2C communication.
void Dino::i2cBegin() {
  I2c.begin();
  // I2c.setSpeed(??);
  // I2c.pullup(??);
  // I2c.timeOut(??);

  // This format could be better.
  stream->print(SDA);   stream->print(':');
  stream->print("I2C"); stream->print(':');
  stream->print('1');   stream->print('\n');
}


// CMD = 32
// Stop I2C communication.
void Dino::i2cEnd() {
  I2c.end();

  // This format could be better.
  stream->print(SDA);   stream->print(':');
  stream->print("I2C"); stream->print(':');
  stream->print('0');   stream->print('\n');
}


// CMD = 33
// Scan for I2C devices.
//
// WARNING: This takes a long time! Try to record the device addresses
// results and put them into your code.
//
// Returns each found address as if a separate reading from SDA pin, eg. "18:104".
// Returns 128 as if read from SDA pin for search complete, eg. "18:128".
// Returns 255 as if read from SDA pin for I2C errors, eg. "18:255".
//
void Dino::i2cScan() {
  uint8_t address = 0;
  while (address < 128) {
    // Scan for the next device.
    address = I2c.scanOne(address);

    // Write whatever we get including address space end or errors.
    stream->print(SDA);     stream->print(':');
    stream->print(address); stream->print('\n');

    // Increment address before scanning again.
    address++;
  }
}


// CMD = 34
// Write to an I2C device.
// All parameters need to be sent in binary in the auxMsg.
//
// auxMsg[0]  = device address
// auxMsg[1]  = register start address
// auxMsg[2]  = number of bytes
// auxMsg[3]+ = data
//
// Limited to 255 bytes. Validate on remote end.
//
void Dino::i2cWrite() {
  I2c.write(auxMsg[0], auxMsg[1], &auxMsg[3], auxMsg[2]);
}


// CMD = 35
// Read from an I2C device.
// All params need to be sent in binary in the auxMsg.
//
// auxMsg[0]  = device address
// auxMsg[1]  = register start address
// auxMsg[2]  = number of bytes
//
// Streams data back in comma delimited ASCII decimal for now,
// matching shiftRead and readSPI. Limited to 32 bytes by I2C library buffer.
// Validate on remote end.
//
void Dino::i2cRead() {
  // Force length to be min 1, max 32.
  if (auxMsg[2] > 32) auxMsg[2] = 32;
  if (auxMsg[2] == 0) auxMsg[2] =  1;

  // Read all the bytes into the library buffer.
  I2c.read(auxMsg[0], auxMsg[1], auxMsg[2]);

  // Send back the SDA pin, the device address, and start register address first.
  stream->print(SDA);       stream->print(':');
  stream->print(auxMsg[0]); stream->print(':');
  stream->print(auxMsg[1]); stream->print(':');

  // Send back the data bytes.
  uint8_t currentByte = 0;
  while(I2c.available()){
    currentByte++;

    // Get a byte from the I2C buffer, print it, then comma or \n if last byte.
    stream->print(I2c.receive());
    stream->print((currentByte == auxMsg[2]) ? '\n' : ',');
  }
}

#endif
