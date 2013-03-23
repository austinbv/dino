#include "Dino.h"
#include <Servo.h>
Dino dino;

// Dino.h doesn't handle TXRX. Setup a function to tell it to write to Serial.
void writeResponse(char *response) { Serial.print(response); Serial.print("\n"); }
void (*writeCallback)(char *str) = writeResponse;

void setup() {
  Serial.begin(115200);
  dino.setupWrite(writeCallback);
}

void loop() {
  while(Serial.available() > 0) dino.parse(Serial.read());
  dino.updateListeners();
  Serial.flush();
}

