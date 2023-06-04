#include "Dino.h"

Dino dino;

// Define 'serial' as the serial interface to use.
// Uses SerialUSB (left port), which is native USB, on Arduino Due and Zero, or Serial otherwise.
// On many boards, eg. Arduino Due, RP2040, Serial may be native USB anyway.
#if defined(__SAM3X8E__) || defined(__SAMD21G18A__)
  #define serial SerialUSB
  // Use this for Programming USB port (right) on Due and Zero.
  // #define serial Serial
#else
  #define serial Serial
#endif

void setup() {
  // Wait for serial ready.
  serial.begin(115200);
  while(!serial);

  // Pass serial stream to dino so it can read/write.
  dino.stream = &serial;

  // Add listener callbacks for local logic.
  dino.digitalListenCallback = onDigitalListen;
  dino.analogListenCallback = onAnalogListen;
}

void loop() {
  dino.run();
}

// This runs every time a digital pin that dino is listening to changes value.
// p = pin number, v = current value
void onDigitalListen(byte p, byte v){
}

// This runs every time an analog pin that dino is listening to gets read.
// p = pin number, v = read value
void onAnalogListen(byte p, int v){
}
