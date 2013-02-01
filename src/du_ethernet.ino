#include "Dino.h"
#include <SPI.h>
#include <Ethernet.h>

// Configure your MAC address, IP address, and HTTP port here.
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
IPAddress ip(192,168,0,77);
int port = 80;

Dino dino;
EthernetServer server(port);
char c;
int index = 0;
char request[8];
char response[9];
char listenerResponses[22][9];

void setup() {
  // Explicitly disable the SD card.
  pinMode(4,OUTPUT);
  digitalWrite(4,HIGH);
  
  // Start up the network connection and server.
  Ethernet.begin(mac, ip);
  server.begin();
    
  // Start serial for debugging.
  Serial.begin(115200);
  Serial.print("Dino::TCP started at ");
  Serial.print(Ethernet.localIP());
  Serial.print(" on port ");
  Serial.println(port);
}


void loop() {
  // Listen for connections.
  EthernetClient client = server.available();

  // Handle a connection.
  if (client) {
    index = 0;
    strcpy(response, "");
    
    while (client.connected()) {
      while (client.available()) {
        c = client.read();
        
        // Reset the request and response when the beginning delimiter is received.
        if (c == '!') {
          index = 0;
          strcpy(response, "");
        }
        
        // Catch the request's ending delimiter and process the request.
        else if (c == '.') {
          dino.process(request, response);
          if(response != "") client.println(response);
        }

        else request[index++] = c;
      }
    }
    client.stop();
  }
}
