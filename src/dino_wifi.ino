#include "Dino.h"
#ifdef ESP8266
  #include <ESP8266WiFi.h>
  #define LED_PIN 2
#else
  #include <SPI.h>
  #include <WiFi.h>
  #define LED_PIN 13
#endif

// Configure your WiFi options here. IP address is not configurable. Uses DHCP.
int port = 3466;
char* ssid = "yourNetwork";
char* pass = "yourPassword";

Dino dino;
WiFiServer server(port);
WiFiClient client;


// Use the built in LED to indicate WiFi status.
void indicate(byte value) {
 #ifdef ESP8266
   digitalWrite(LED_PIN, !value);
 #else
  digitalWrite(LED_PIN, value);
 #endif
}


void printWifiStatus() {
  Serial.println("Connected");
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());
  Serial.print("Signal Strength (RSSI):");
  Serial.print(WiFi.RSSI());
  Serial.println(" dBm");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
  Serial.print("Dino TCP Port: ");
  Serial.println(port);
  indicate(true);
}


void connect(){
  Serial.print("Attempting to connect to SSID: ");
  Serial.print(ssid);
  WiFi.begin(ssid, pass);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  printWifiStatus();
}


void setup() {
  pinMode(LED_PIN, OUTPUT);

  // Start serial for debugging.
  Serial.begin(115200);
  while(!Serial);

  connect();
  server.begin();

  dino.digitalListenCallback = onDigitalListen;
  dino.analogListenCallback = onAnalogListen;
}

void loop() {
  // Reconnect if we've lost WiFi..
  if (WiFi.status() != WL_CONNECTED){
    indicate(false);
    connect();
  }

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
