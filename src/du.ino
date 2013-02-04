#include "Dino.h"

Dino dino;
char c;
int index = 0;
char request[8];

void setup() {
  Serial.begin(115200);
}

void loop() {
  while(Serial.available() > 0) {
    c = Serial.read();

    // Reset request when the beginning delimiter is received.
    if (c == '!') {
      index = 0;
    } 
    
    // Catch the request's ending delimiter and process the request.
    else if (c == '.') {
      dino.process(request);
      writeResponses();
    }
       
    else request[index++] = c;
  }
  
  // Update listeners if it's time.
  if (dino.updateReady()) {
    dino.updateListeners();
    writeResponses();
  }
}

void writeResponses() {
  for (int i = 0; i < dino.responseCount; i++) {
    Serial.println(dino.responses[i]);
  }
}
