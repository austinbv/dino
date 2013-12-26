#include "Dino.h"
#include <Servo.h>
#include <LiquidCrystal.h>
#include "DHT.h"

// SoftwareSerial doesn't work on the Due yet.
#if !defined(__SAM3X8E__)
  #include <SoftwareSerial.h>
#endif

Dino dino;

// Use 'serial' to reference the right interface depending on the device.
// Uses native USB connection on the Due by default.
#if defined(__SAM3X8E__)
  Serial_ &serial = SerialUSB;
#elif defined(__AVR_ATmega32U4__)
  Serial_ &serial = Serial;
#else
  HardwareSerial &serial = Serial;
#endif

// Dino.h doesn't handle TXRX. Create a callback so it can write to serial.
void writeResponse(char *response) { serial.print(response); }
void (*writeCallback)(char *str) = writeResponse;

void setup() {
  serial.begin(115200);
  
  // Wait for Leonardo serial port to connect.
  #if defined(__AVR_ATmega32U4__)
    while(!serial);
  #endif

  dino.setupWrite(writeCallback);
}

void loop() {
  while(serial.available() > 0) dino.parse(serial.read());
  dino.updateListeners();
}
