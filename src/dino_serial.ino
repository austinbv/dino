#include "Dino.h"

Dino dino;

// Use 'serial' as a pointer to the serial interface depending on device.
// Uses native USB connection on the Due by default.
#if defined(__SAM3X8E__)
  Serial_* serial = &SerialUSB;
#elif defined(__AVR_ATmega32U4__)
  Serial_* serial = &Serial;
#elif defined(__AVR_ATtiny85__)
  TinyDebugSerial* serial = &Serial;
#else
  HardwareSerial* serial = &Serial;
#endif


void setup() {
  serial->begin(115200);

  // Wait for Leonardo serial port to connect.
  #if defined(__AVR_ATmega32U4__)
    while(!serial);
  #endif

  // Pass the serial pointer to dino, so it can write too.
  dino.setOutputStream(serial);
}


// Keep count of bytes as we receive them and send a dino message with how many.
uint8_t rcvBytes  = 0;
uint8_t rcvThreshold = 30;
long    lastRcv   = micros();
long    rcvWindow = 1000000;

void acknowledge() {
  serial->print("RCV:");
  serial->print(rcvBytes);
  serial->print("\n");
  rcvBytes = 0;
}


void loop() {
  while(serial->available() > 0) {
    dino.parse(serial->read());

    // Acknowledge when we've received as many bytes as the serial input buffer.
    lastRcv = micros();
    rcvBytes ++;
    if (rcvBytes == rcvThreshold) acknowledge();
  }

  // Also acknowledge when the last byte received goes outside the receive window.
  if ((rcvBytes > 0) && ((micros() - lastRcv) > rcvWindow)) acknowledge();

  // Run dino's listeners.
  dino.updateListeners();
}
