#include "Dino.h"
#include <SPI.h>
#include <Ethernet.h>

// Configure your MAC address, IP address, and HTTP port here.
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
IPAddress ip(192,168,0,77);
int port = 80;

Dino dino;
EthernetServer server(port);
// String url = "";
char request[8];
int index = 0;
String response = "";

void setup() {
  // Start up the network connection and server.
  Ethernet.begin(mac, ip);
  server.begin();
  
  // Start serial for debugging.
  Serial.begin(115200);
  Serial.print("Dino TCP client started at ");
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
    response = "";
    while (client.connected()) {
      if (client.available()) {
        char c = client.read();
        
        // Reset the request and response when the beginning delimiter is received.
        if (c == '!') {
          index = 0;
          response = "";
        }
        
        // Catch the request's ending delimiter and process the request.
        else if (c == '.') {
          dino.process(request, &response);
          if(response != "") client.println(response);
        }

        else request[index++] = c;
      }
    }
    client.stop();
  }
}
