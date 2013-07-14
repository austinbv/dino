#include "Dino.h"
#include <Servo.h>
#include <LiquidCrystal.h>
#include <SoftwareSerial.h>
Dino dino;

// Use the native serial port on the Arduino Due
#if defined(__SAM3X8E__)
  Serial_ serial = SerialUSB;
#else
  HardwareSerial serial = Serial;
#endif

// Dino.h doesn't handle TXRX. Setup a function to tell it to write to Serial.
void writeResponse(char *response) { serial.print(response); serial.print("\n"); }
void (*writeCallback)(char *str) = writeResponse;

void setup() {
  Serial.begin(115200);
  dino.setupWrite(writeCallback);
}

void loop() {
  while(serial.available() > 0) dino.parse(serial.read());
  dino.updateListeners();
  serial.flush();
}
