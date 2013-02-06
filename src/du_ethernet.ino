#include "Dino.h"
#include <SPI.h>
#include <Ethernet.h>

// Configure your MAC address, IP address, and HTTP port here.
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
IPAddress ip(192,168,0,77);
int port = 80;

Dino dino;
EthernetServer server(port);
EthernetClient client;

// Dino.h doesn't handle TXRX. Setup a function to tell it to write to the TCP socket.
void writeResponse(char *response) { client.println(response); }
void (*writeCallback)(char *str) = writeResponse;

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
  
  // Attach the write callback.
  dino.setupWrite(writeCallback);                  
}

void loop() {
  // Listen for connections.
  client = server.available();
  
  // Handle a connection.
  if (client) {
    while (client.connected()) {
      while (client.available()) dino.parse(client.read());
      dino.updateListeners();
    }
    client.stop();
  }
}

