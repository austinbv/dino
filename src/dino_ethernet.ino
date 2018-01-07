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

  // Pass a client pointer to dino, so it can write too.
  dino.setOutputStream(&client);
}


// Keep count of bytes as we receive them and send a dino message with how many.
uint8_t rcvBytes  = 0;
uint8_t rcvThreshold = 30;
long    lastRcv   = micros();
long    rcvWindow = 1000000;

void acknowledge() {
  client.print("RCV:");
  client.print(rcvBytes);
  client.print("\n");
  rcvBytes = 0;
}

void loop() {
  // Listen for connections.
  client = server.available();

  // Handle a connection.
  if (client) {
    while (client.connected()) {
      while (client.available()){
        dino.parse(client.read());

        // Acknowledge when we've received as many bytes as the serial input buffer.
        lastRcv = micros();
        rcvBytes ++;
        if (rcvBytes == rcvThreshold) acknowledge();
      }

      // Also acknowledge when the last byte received goes outside the receive window.
      if ((rcvBytes > 0) && ((micros() - lastRcv) > rcvThreshold)) acknowledge();

      dino.updateListeners();
    }
  }
  client.stop();
}
