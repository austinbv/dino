//
// This file adds to the Dino class only if DINO_SPI is defined in Dino.h.
//
#include "Dino.h"
#ifdef DINO_SPI

#include <SPI.h>

// Define listeners for SPI registers.
#define SPI_LISTENER_COUNT 4
struct SpiListener{
  byte     selectPin;
  byte     settings;
  byte     len;
  uint32_t clockRate;
  boolean  enabled;
};
SpiListener spiListeners[SPI_LISTENER_COUNT];


// Convenience wrapper for SPI.begin
void Dino::spiBegin(byte settings, uint32_t clockRate){
  SPI.begin();

  byte bitOrder;
  if bitRead(settings, 7) {
    bitOrder = MSBFIRST;
  } else {
    bitOrder = LSBFIRST;
  }

  byte mode = settings;
  bitClear(mode, 7);

  SPI.beginTransaction(SPISettings(clockRate, bitOrder, mode));
}


// Convenience wrapper for SPI.end
void Dino::spiEnd(){
  SPI.endTransaction();
  // If the sketch is using SPI for TxRx (Wi-Fi/Ethernet) we don't want to end.
  // CLI generator will define TXRX_SPI in Dino.h for those cases.
  #ifndef TXRX_SPI
    SPI.end();
  #endif
}


//
// Request format for SPI 2-way transfers
// pin         = slave select pin (int)
// val         = empty
// auxMsg[0]   = SPI settings. 2 LSB = SPI mode. Bit 7 = MSB(1) / LSB(0).
// auxMsg[1]   = write length (number of bytes)
// auxMsg[2]   = read length  (number of bytes)
// auxMsg[3-6] = clock frequency (uint32_t as 4 bytes)
//
// auxMsg[7]+  = data (bytes) (write only)
//
// CMD = 26
// Write to an SPI device.
void Dino::spiTransfer(int selectPin, byte settings, byte rLength, byte wLength, uint32_t clockRate, byte *data) {

  spiBegin(settings, clockRate);
  digitalWrite(selectPin, LOW);

  if (rLength > 0) {
    // Stream read bytes as if coming from select pin for easy identification.
    stream->print(selectPin);
    stream->print(':');
  }

  for (byte i = 0;  (i < rLength || i < wLength);  i++) {
    byte b;

    if (i < wLength) {
      b = SPI.transfer(data[i]);
    } else {
      b = SPI.transfer(0x00);
    }

    if (i < rLength) {
      // Print read byte, then a comma or \n if it's the last read byte.
      stream->print(b);
      stream->print((i+1 == rLength) ? '\n' : ',');
    }
  }
  spiEnd();

  // Leave select high.
  digitalWrite(selectPin, HIGH);
}


// CMD = 27
// Start listening to an SPI register.
// Overwrite the first disabled listener in the struct array.
void Dino::addSpiListener(int selectPin, byte settings, byte rLength, byte wLength, uint32_t clockRate) {
  for (int i = 0;  i < SPI_LISTENER_COUNT;  i++) {
    if (spiListeners[i].enabled == false) {
      spiListeners[i] = {
        selectPin,
        settings,
        rLength,
        clockRate,
        true
      };
      return;
    } else {
    // Should send some kind of error if all are in use.
    }
  }
}

// CMD = 28
// Send a number for a select pin to remove an SPI register listener.
void Dino::removeSpiListener(){
  for (int i = 0;  i < SPI_LISTENER_COUNT;  i++) {
    if (spiListeners[i].selectPin == pin) {
      spiListeners[i].enabled = false;
    }
  }
}


// Gets called by Dino::updateListeners to run listeners in the main loop.
void Dino::updateSpiListeners(){
  for (int i = 0; i < SPI_LISTENER_COUNT; i++) {
    if (spiListeners[i].enabled) {
      spiTransfer(spiListeners[i].selectPin,
                  spiListeners[i].settings,
                  spiListeners[i].len,
                  0,
                  spiListeners[i].clockRate,
                  {});
    }
  }
}


// Gets called by Dino::reset to clear all listeners.
void Dino::clearSpiListeners(){
  for (int i = 0; i < SPI_LISTENER_COUNT; i++) spiListeners[i].enabled = false;
}

#endif
