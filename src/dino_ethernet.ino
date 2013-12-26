#include "Dino.h"
#include <SPI.h>
#include <Ethernet.h>
#include <Servo.h>
#include <LiquidCrystal.h>
#include "DHT.h"

// SoftwareSerial doesn't work on the Due yet.
#if !defined(__SAM3X8E__)
  #include <SoftwareSerial.h>
#endif

// Configure your MAC address, IP address, and HTTP port here.
byte mac[] = { 0xDE, 0xAD, 0xBE, 0x30, 0x31, 0x32 };
IPAddress ip(192,168,0,77);
int port = 3466;

Dino dino;
EthernetServer server(port);
EthernetClient client;
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
