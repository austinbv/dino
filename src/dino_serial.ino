#include "Dino.h"

Dino dino;

// Define 'serial' as the serial interface we want to use.
// Defaults to Native USB port on the Due, whatever class "Serial" is on everything else.
// Classes need to inherit from Stream to be compatible with the Dino library.
#if defined(__SAM3X8E__)
#define serial SerialUSB
//#define serial Serial
#else
#define serial Serial
#endif


void setup() {
  // Wait for serial ready.
  serial.begin(115200);
  while(!serial);

  // Pass serial stream to dino so it can read/write.
  dino.setOutputStream(&serial);
}

void loop() {
  dino.run();
}
