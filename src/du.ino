#include "Dino.h"
Dino dino;
char c;
int index = 0;
char request[8];

// Dino.h doesn't handle TXRX. Setup a function to tell it to write to Serial.
void writeResponse(char *response) { Serial.println(response); }
void (*writeCallback)(char *str) = writeResponse;

void setup() {
  Serial.begin(115200);
  dino.setupWrite(writeCallback);                // Attach the callback so Dino can write
}

void loop() {
  while(Serial.available() > 0) {
    c = Serial.read();
    if (c == '!') index = 0;                     // Reset request
    else if (c == '.') dino.process(request);    // End request and process
    else request[index++] = c;                   // Append to request
  }
  
  dino.updateListeners();
}

