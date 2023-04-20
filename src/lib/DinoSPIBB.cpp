//
// This file adds SPI bitbang functionality to the Dino class if DINO_SPI_BB is defined.
//
#include "Dino.h"
#ifdef DINO_SPI_BB

// Define listeners for SPI BitBang registers.
#define SPI_BB_LISTENER_COUNT 4
struct spiBBlistener {
  byte     select;
  byte     settings;
  byte     clock;
  byte     input;
  byte     length;
  boolean  enabled;
};
spiBBlistener spiBBlisteners[SPI_BB_LISTENER_COUNT];

// CMD = 21
//
// Request format for bit banged SPI 2-way transfers
// pin         = select pin
// val         = empty
// auxMsg[0]   = SPI settings
//   Bit 0..1  = SPI mode
//   Bit 2..6  = ** unused **
//   Bit 7     = Read and write bit order: MSBFIRST(1) or LSBFIRST(0)
// auxMsg[1]   = read length  (number of bytes)
// auxMsg[2]   = write length (number of bytes)
// auxMsg[3]   = clock pin  (uint8)
// auxMsg[4]   = input pin  (uint8) - Set to 255 for one-way transfer.
// auxMsg[5]   = output pin (uint8) - Set to 255 for one-way transfer.
// auxMsg[6]   = ** unused **
// auxMsg[7+]  = data (bytes) (write only) - Start from 7 for parity with hardware SPI.
//
void Dino::spiBBtransfer( uint8_t settings, uint8_t select, uint8_t clock, uint8_t input, uint8_t output,
                          uint8_t rLength, uint8_t wLength, byte *data) {

  // Mode is the lowest 2 bits of settings.
  uint8_t mode = settings & 0b00000011;

  // Bit order is stored in the highest bit of settings.
  uint8_t bitOrder = (settings & 0b10000000) >> 7;

  // Set modes for input and output pins.
  // Use a pin number of 255 to avoid touching either.
  if (output < 255) pinMode(output, OUTPUT);
  if (input < 255)  pinMode(input, INPUT);

  // Set idle state of clock pin based on SPI mode.
  pinMode(clock, OUTPUT);
  if ((mode == 0)||(mode == 1)) digitalWrite(clock, LOW);
  if ((mode == 2)||(mode == 3)) digitalWrite(clock, LOW);

  // Stream read bytes as if coming from select pin.
  if (rLength > 0) {
    stream->print(select);
    stream->print(':');
  }

  // Pull select pin low.
  pinMode(select, OUTPUT);
  digitalWrite(select, LOW);

  for (byte i = 0;  (i < rLength || i < wLength);  i++) {
    byte b;

    if (i < wLength) {
      b = spiBBtransferByte(select, clock, input, output, mode, bitOrder, data[i]);
    } else {
      b = spiBBtransferByte(select, clock, input, output, mode, bitOrder, 0x00);
    }

    if (i < rLength) {
      // Print read byte, then a comma or \n if it's the last read byte.
      stream->print(b);
      stream->print((i+1 == rLength) ? '\n' : ',');
    }
  }
  
  // Leave select high.
  digitalWrite(select, HIGH);
}

//
// Used by spiBBtransfer to transfer a single byte at a time.
//
byte Dino::spiBBtransferByte(uint8_t select, uint8_t clock, uint8_t input, uint8_t output, uint8_t mode, uint8_t bitOrder, byte data) {
  // Byte to return
  byte b = 0x00;
  
  // Track which of the 8 bits we're on.
  uint8_t bitPos;

  // Read and write 8 bits.
  for (int i=0; i<8; i++) {
    // Set which bit index is being read and written based on i and bit orders.
    if (bitOrder == 0) { bitPos = i; } else { bitPos = 7 - i; }

    // SPI MODE 0
    if (mode == 0){
      if (output < 255) digitalWrite(output, bitRead(data, bitPos));
      digitalWrite(clock, HIGH);
      if (input < 255) bitWrite(b, bitPos, digitalRead(input));
      digitalWrite(clock, LOW);
    }

    // SPI MODE 1
    if (mode == 1){
      digitalWrite(clock, HIGH);
      if (output < 255) digitalWrite(output, bitRead(data, bitPos));
      digitalWrite(clock, LOW);
      if (input < 255) bitWrite(b, bitPos, digitalRead(input));
    }

    // SPI MODE 2
    if (mode == 2){
      if (output < 255) digitalWrite(output, bitRead(data, bitPos));
      digitalWrite(clock, LOW);
      if (input < 255) bitWrite(b, bitPos, digitalRead(input));
      digitalWrite(clock, HIGH);
    }

    // SPI MODE 3
    if (mode == 3){
      digitalWrite(clock, LOW);
      if (output < 255) digitalWrite(output, bitRead(data, bitPos));
      digitalWrite(clock, HIGH);
      if (input < 255) bitWrite(b, bitPos, digitalRead(input));
    }
  }
  return b;
}

// CMD = 22
// Start listening to a register with bit bang SPI.
void Dino::spiBBaddListener() {
  for (int i = 0;  i < SPI_BB_LISTENER_COUNT;  i++) {
    // Overwrite the first disabled listener in the struct array.
    if (spiBBlisteners[i].enabled == false) {
      spiBBlisteners[i] = {
        pin,
        auxMsg[0],
        auxMsg[3],
        auxMsg[4],
        auxMsg[1],
        true
      };
      return;
    } else {
    // Should send some kind of error if all are in use.
    }
  }
}

// CMD = 23
// Send a select pin number to remove a bit bang SPI listener.
void Dino::spiBBremoveListener() {
  for (int i = 0;  i < SPI_BB_LISTENER_COUNT;  i++) {
    if (spiBBlisteners[i].select == pin) {
      spiBBlisteners[i].enabled = false;
    }
  }
}

// Gets called by Dino::updateListeners to run listeners in the main loop.
void Dino::spiBBupdateListeners() {
  for (int i = 0; i < SPI_BB_LISTENER_COUNT; i++) {
    if (spiBBlisteners[i].enabled) {
      spiBBtransfer(  spiBBlisteners[i].settings,
                      spiBBlisteners[i].select,
                      spiBBlisteners[i].clock,
                      spiBBlisteners[i].input,
                      255,       // 255 means no output pin
                      spiBBlisteners[i].length,
                      0,         // 0 bytes written to output
                      &auxMsg[0] // Point at any char array since it won't be touched.
                   );
    }
  }
}

// Gets called by Dino::reset to clear all listeners.
void Dino::spiBBclearListeners() {
  for (int i = 0; i < SPI_BB_LISTENER_COUNT; i++) spiBBlisteners[i].enabled = false;
}
#endif
