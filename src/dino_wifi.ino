#include "Dino.h"
#include <SPI.h>
#include <WiFi.h>

// Configure your WiFi options here. MAC address and IP address are not configurable.
int port = 3466;
char ssid [] = "yourNetwork";
char pass [] = "yourPassword";
int keyIndex = 0;
int status = WL_IDLE_STATUS;

Dino dino;
WiFiServer server(port);
WiFiClient client;


void printWifiStatus() {
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());
  Serial.print("Signal Strength (RSSI):");
  Serial.print(WiFi.RSSI());
  Serial.println(" dBm");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
  Serial.print("Port: ");
  Serial.println(port);
}


void setup() {
  // Start serial for debugging.
  Serial.begin(9600);

  // Try to connect to the specified network.
  while ( status != WL_CONNECTED) {
    Serial.print("Attempting to connect to SSID: ");
    Serial.println(ssid);
    status = WiFi.begin(ssid, pass);
    delay(10000);
  }

  // Start the server.
  server.begin();
  printWifiStatus();

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
      if ((rcvBytes > 0) && ((micros() - lastRcv) > rcvWindow)) acknowledge();

      dino.updateListeners();
    }
  }
  client.stop();
}
