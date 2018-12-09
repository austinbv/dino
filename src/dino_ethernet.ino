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
  Serial.print("IP Address: ");
  Serial.println(Ethernet.localIP());
  Serial.print("Port: ");
  Serial.println(port);
}


void setup() {
  // Start serial for debugging.
  Serial.begin(115200);
  while(!serial);

  // Explicitly disable the SD card.
  pinMode(4,OUTPUT);
  digitalWrite(4,HIGH);

  // Start up the network connection and server.
  Ethernet.begin(mac, ip);
  server.begin();
  printEthernetStatus();

  dino.digitalListenCallback = onDigitalListen;
  dino.analogListenCallback = onAnalogListen;
}


void loop() {
  // Listen for connections.
  client = server.available();

  // Pass the stream to dino so it can read/write.
  dino.stream = &client;

  // Handle a connection.
  if (client) {
    while (client.connected()) dino.run();
  }

  // End the connection.
  client.stop();
}

// This runs every time a digital pin that dino is listening to changes value.
// p = pin number, v = current value
void onDigitalListen(byte p, byte v){
}

// This runs every time an analog pin that dino is listening to gets read.
// p = pin number, v = read value
void onAnalogListen(byte p, int v){
}
