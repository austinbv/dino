#include "Dino.h"

char request[8];
int index = 0;
String response = "";
Dino dino;

void setup() {
  Serial.begin(115200);
}

void loop() {
  while(Serial.available() > 0) {
    char c = Serial.read();

    // Reset the request and response when the beginning delimiter is received.
    if (c == '!') {
      index = 0;
      response = "";
    } 
    
    // Catch the request's ending delimiter and process the request.
    else if (c == '.') {
      dino.process(request, &response);
      if(response != "") Serial.println(response);
    }
       
    else request[index++] = c;
  }
}
