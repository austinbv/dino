#include "Dino.h"
#include <SPI.h>
#include <WiFi.h>

// SoftwareSerial doesn't work on the Due yet.
#if !defined(__SAM3X8E__)
  #include <SoftwareSerial.h>
#endif

// Configure your WiFi options here. MAC address and IP address are not configurable.
int port = 3466;
char ssid [] = "yourNetwork";
char pass [] = "yourPassword";
int keyIndex = 0;
int status = WL_IDLE_STATUS;

Dino dino;
WiFiServer server(port);
WiFiClient client;
char responseBuffer[65];


// Dino.h doesn't handle TXRX.
// Setup a callback to buffer responses for writing.
void bufferResponse(char *response) {
  if (strlen(responseBuffer) > 56 ) writeResponses();
  strcpy(responseBuffer, response);
}
void (*writeCallback)(char *str) = bufferResponse;

// Write the buffered responses to the client.
void writeResponses() {
  if (responseBuffer[0] != '\0')
    client.write(responseBuffer);
    responseBuffer[0] = '\0';
}

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
      writeResponses();
    }
  }
  client.stop();
}
