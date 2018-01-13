#include "Dino.h"
#include <SPI.h>
#include <Ethernet.h>

// Configure your MAC address, IP address, and HTTP port here.
byte mac[] = { 0xDE, 0xAD, 0xBE, 0x30, 0x31, 0x32 };
IPAddress ip(192,168,0,77);
int port = 3466;

Dino dino;
EthernetServer server(port);
EthernetClient client;


void printEthernetStatus() {
  // Print ethernet status.
  Serial.print("IP Address: ");
  Serial.println(Ethernet.localIP());
  Serial.print("Port: ");
  Serial.println(port);
}


void setup() {
  // Start serial for debugging.
  Serial.begin(9600);

  // Explicitly disable the SD card.
  pinMode(4,OUTPUT);
  digitalWrite(4,HIGH);

  // Start up the network connection and server.
  Ethernet.begin(mac, ip);
  server.begin();
  printEthernetStatus();
}


void loop() {
  // Listen for connections.
  client = server.available();

  // Pass the stream to dino so it can read/write.
  dino.setOutputStream(&client);

  // Handle a connection.
  if (client) {
    while (client.connected()) dino.run();
  }

  // End the connection.
  client.stop();
}
