#include "SrStuduino.h"
#include <Servo.h>
#include <Wire.h>
#include <MMA8653.h>
#include "Studuino.h"

SrStuduino smalrubot;

// Smalrubot.h doesn't handle TXRX. Setup a function to tell it to write to Serial.
void writeResponse(char *response) { Serial.println(response); }
void (*writeCallback)(char *str) = writeResponse;

void setup() {
  Serial.begin(19200);
  smalrubot.setupWrite(writeCallback);
}

void loop() {
  while(Serial.available() > 0) smalrubot.parse(Serial.read());
  Serial.flush();
}

