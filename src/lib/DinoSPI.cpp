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
  byte     len;
  byte     spiMode;
  uint32_t clockRate;
  boolean  enabled;
};
SpiListener spiListeners[SPI_LISTENER_COUNT];


// Convenience wrapper for SPI.begin
void Dino::spiBegin(byte spiMode, uint32_t clockRate){
  SPI.begin();
  // Should make LSB/MSB optional.
  switch(spiMode) {
    case 0:  SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE0)); break;
    case 1:  SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE1)); break;
    case 2:  SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE2)); break;
    case 3:  SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE3)); break;
  }
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
// Request format for single direction SPI API functions.
// pin         = slave select pin (int)
// val         = length (int)
// auxMsg[0]   = SPI mode (byte)
// auxMsg[1-4] = clock frequency (uint32_t as 4 bytes)
// auxMsg[5]+  = data (bytes) (write func only)
//
// CMD = 26
// Write to an SPI device.
void Dino::spiWrite(int selectPin, int len, byte spiMode, uint32_t clockRate, byte *data) {
  spiBegin(spiMode, clockRate);

  // Select the device.
  digitalWrite(selectPin, LOW);

  // Write one byte at a time.
  for (uint8_t i = 0;  i < len;  i++) {
    SPI.transfer(data[i]);
  }
  spiEnd();

  // Leave select high.
  digitalWrite(selectPin, HIGH);
}


// CMD = 27
// Read from an SPI device.
void Dino::spiRead(int selectPin, int len, byte spiMode, uint32_t clockRate) {
  spiBegin(spiMode, clockRate);

  // Select the device.
  digitalWrite(selectPin, LOW);

  // Send data as if coming from the slave select pin so it's easy to identify.
  // Start with just pin number and : for now.
  sprintf(response, "%d:", selectPin);
  _writeCallback(response);

  for (int i = 1;  i <= len;  i++) {
    // Read a single byte from the register.
    byte reading = SPI.transfer(0x00);

    // If we're on the last byte, append \n. If not, append a comma, then write.
    if (i == len) {
      sprintf(response, "%d\n", reading);
    } else {
      sprintf(response, "%d,", reading);
    }
    _writeCallback(response);
  }
  spiEnd();

  // Leave select high and clear response so main loop doesn't send anything.
  digitalWrite(selectPin, HIGH);
  response[0] = '\0';
}

// CMD = 28
// Start listening to an SPI register.
// Overwrite the first disabled listener in the struct array.
void Dino::addSpiListener(int selectPin, int len, byte spiMode, uint32_t clockRate) {
  for (int i = 0;  i < SPI_LISTENER_COUNT;  i++) {
    if (spiListeners[i].enabled == false) {
      spiListeners[i] = {
        selectPin,
        len,
        spiMode,
        clockRate,
        true
      };
      return;
    } else {
    // Should send some kind of error if all are in use.
    }
  }
}

// CMD = 29
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
      spiRead(spiListeners[i].selectPin,
              spiListeners[i].len,
              spiListeners[i].spiMode,
              spiListeners[i].clockRate);
    }
  }
}


// Gets called by Dino::reset to clear all listeners.
void Dino::clearSpiListeners(){
  for (int i = 0; i < SPI_LISTENER_COUNT; i++) spiListeners[i].enabled = false;
}

#endif
