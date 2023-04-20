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

  // SPI mode is the lowest 2 bits of settings.
  byte mode = settings & 0B00000011;
  
  // Bit 7 of settings controls bit order. 0 = LSBFIRST, 1 = MSBFIRST.
  if (bitRead(settings, 7) == 0) {
    // True integer value for these macros vary by platform, so just do this.
    switch(mode){
      case 0: SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE0)); break;
      case 1: SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE1)); break;
      case 2: SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE2)); break;
      case 3: SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, SPI_MODE3)); break;
    }
  } else {
    switch(mode){
      case 0: SPI.beginTransaction(SPISettings(clockRate, MSBFIRST, SPI_MODE0)); break;
      case 1: SPI.beginTransaction(SPISettings(clockRate, MSBFIRST, SPI_MODE1)); break;
      case 2: SPI.beginTransaction(SPISettings(clockRate, MSBFIRST, SPI_MODE2)); break;
      case 3: SPI.beginTransaction(SPISettings(clockRate, MSBFIRST, SPI_MODE3)); break;
    }
  }
}

// Convenience wrapper for SPI.end
void Dino::spiEnd(){
  SPI.endTransaction();
  // TXRX_SPI in defined for WiFi/Ethernet sketches on AVR chips.
  // In those cases, SPI.end() can't be called since the network hardware uses it.
  // ESP32 doesn't like when SPI.end is called either. Might be safe to never do it.
  #if !defined(TXRX_SPI) && defined(__AVR__)
    SPI.end();
  #endif
}

// CMD = 26
// Simultaneous read from and write to an SPI device.
//
// Request format for SPI 2-way transfers
// pin         = select pin
// val         = empty
// auxMsg[0]   = SPI settings
//   Bit 0..1  = SPI mode
//   Bit 2..6  = unused
//   Bit 7     = MSBFIRST(1) or LSBFIRST(0)
// auxMsg[1]   = read length  (number of bytes)
// auxMsg[2]   = write length (number of bytes)
// auxMsg[3-6] = clock frequency (uint32_t as 4 bytes)
// auxMsg[7+]  = data (bytes) (write only)
//
void Dino::spiTransfer(uint8_t selectPin, uint8_t settings, uint8_t rLength, uint8_t wLength, uint32_t clockRate, byte *data) {
  spiBegin(settings, clockRate);

  // Stream read bytes as if coming from select pin.
  if (rLength > 0) {
    stream->print(selectPin);
    stream->print(':');
  }

  // Pull select pin low.
  pinMode(selectPin, OUTPUT);
  digitalWrite(selectPin, LOW);
  
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

  // Leave select high.
  digitalWrite(selectPin, HIGH);

  spiEnd();
}

// CMD = 27
// Start listening to an SPI register.
void Dino::spiAddListener() {
  for (int i = 0;  i < SPI_LISTENER_COUNT;  i++) {
    // Overwrite the first disabled listener in the struct array.
    if (spiListeners[i].enabled == false) {
      spiListeners[i] = {
        pin,
        auxMsg[0],
        auxMsg[1],
        *reinterpret_cast<uint32_t*>(auxMsg + 3),
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
void Dino::spiRemoveListener(){
  for (int i = 0;  i < SPI_LISTENER_COUNT;  i++) {
    if (spiListeners[i].selectPin == pin) {
      spiListeners[i].enabled = false;
    }
  }
}

// Gets called by Dino::updateListeners to run listeners in the main loop.
void Dino::spiUpdateListeners(){
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
void Dino::spiClearListeners(){
  for (int i = 0; i < SPI_LISTENER_COUNT; i++) spiListeners[i].enabled = false;
}
#endif
