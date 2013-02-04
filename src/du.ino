#include "Dino.h"

Dino dino;
char c;
int index = 0;
char request[8];
char response[9];
char listenerResponses[22][9];

void setup() {
  Serial.begin(115200);
}

void loop() {
  while(Serial.available() > 0) {
    c = Serial.read();

    // Reset the request and response when the beginning delimiter is received.
    if (c == '!') {
      index = 0;
      strcpy(response, "");
    } 
    
    // Catch the request's ending delimiter and process the request.
    else if (c == '.') {
      dino.process(request, response);
      if(response != "") Serial.println(response);
    }
       
    else request[index++] = c;
  }
  
  // Update listeners if it's time.
  if (dino.updateReady()) {
    dino.updateListeners(*listenerResponses);
    for (int i = 0; i < dino.listenerCount; i++) {
      Serial.println(listenerResponses[i]);
    }
  }
}
