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

  // SPI mode is the lowest 4 bits of settings.
  byte mode = settings & 0B00001111;

  // Bit 7 of settings toggles MSBFIRST.
  // Don't try to refactor t his and just pass bit 7.
  // On the Due, MSBFIRST and LSBFIRST are ByteOrder class objects.
  if (bitRead(settings, 7)) {
  	SPI.beginTransaction(SPISettings(clockRate, MSBFIRST, mode));
  } else {
  	SPI.beginTransaction(SPISettings(clockRate, LSBFIRST, mode));
  }
}

// Convenience wrapper for SPI.end
void Dino::spiEnd(){
  SPI.endTransaction();
  // CLI generator will define TXRX_SPI in Dino.h for all WiFi sketches.
  // Only matters if using the SPI-based WiFi Arduino shield. We don't want to end.
  #if !defined(TXRX_SPI) || defined(ESP8266) || defined(ESP32)
    SPI.end();
  #endif
}

// CMD = 26
// Simultaneous read from and write to an SPI device.
//
// Request format for SPI 2-way transfers
// pin         = slave select pin (int)
// val         = empty
// auxMsg[0]   = SPI settings
//   Bit 0..3  = SPI mode
//   Bit 7     = MSBFIRST(1) or LSBFIRST(0)
// auxMsg[1]   = read length  (number of bytes)
// auxMsg[2]   = write length (number of bytes)
// auxMsg[3-6] = clock frequency (uint32_t as 4 bytes)
// auxMsg[7+]  = data (bytes) (write only)
//
void Dino::spiTransfer(int selectPin, byte settings, byte rLength, byte wLength, uint32_t clockRate, byte *data) {
  // Pull select pin low.
  pinMode(selectPin, OUTPUT);
  digitalWrite(selectPin, LOW);
  
  spiBegin(settings, clockRate);

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
void Dino::addSpiListener() {
  for (int i = 0;  i < SPI_LISTENER_COUNT;  i++) {
    // Overwrite the first disabled listener in the struct array.
    if (spiListeners[i].enabled == false) {
      spiListeners[i] = {
        pin,
        auxMsg[0],
        auxMsg[1],
        *((uint32_t*)(auxMsg + 3)),
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
