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
  
  /*
  // Wait for the heartbeat interval.
  delay(dino.heartRate);

  // Get responses for all listeners to and write to serial.
  int responseCount = dino.updateListeners(*listenerResponses);
  for (int i = 0; i < responseCount; i++) {
    Serial.println(listenerResponses[i]);
  }
  */
}
