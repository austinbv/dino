#include "Dino.h"

Dino dino;

// Define 'serial' as the serial interface on teh device that we want to use.
// Defaults to Native USB port on the Due.
#if defined(__SAM3X8E__)
#define serial SerialUSB
//#define serial Serial
#else
#define serial Serial
#endif


void setup() {
  serial.begin(115200);

  // Wait for Leonardo serial port to connect.
  #if defined(__AVR_ATmega32U4__)
    while(!serial);
  #endif

  // Pass the stream to dino so it can read/write.
  dino.setOutputStream(&serial);
}

void loop() {
  dino.run();
}
