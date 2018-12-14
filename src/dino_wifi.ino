#include "Dino.h"
#ifdef ESP8266
  #include <ESP8266WiFi.h>
  #include <ESP8266mDNS.h>
  #include <WiFiUdp.h>
  #include <ArduinoOTA.h>
  #include <EEPROM.h>
  #define LED_PIN 2
#else
  #include <SPI.h>
  #include <WiFi.h>
  #define LED_PIN 13
#endif

// Define 'serial' as the serial interface we want to use.
// Defaults to Native USB port on the Due, whatever class "Serial" is on everything else.
// Classes need to inherit from Stream to be compatible with the Dino library.
#if defined(__SAM3X8E__)
  #define serial SerialUSB
  //#define serial Serial
#else
  #define serial Serial
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
  pinMode(LED_PIN, OUTPUT);
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
  #ifdef debug
    indicate(false);
    Serial.println();
    Serial.print("Attempting to connect to SSID: ");
    Serial.println(ssid);
  #endif

  #ifdef ESP8266
    WiFi.mode(WIFI_STA);
  #endif

  WiFi.begin(ssid, pass);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    #ifdef ESP8266
      Serial.print(".");
    #endif
  }

  #ifdef debug
    printWifiStatus();
  #endif
}

void setup() {
  // Wait for serial ready.
  serial.begin(115200);
  while(!serial);

  // Enable over the air updates and "EEPROM" on the ESP8266.
  #ifdef ESP8266
    EEPROM.begin(512);
    ArduinoOTA.begin();
  #endif

  // Connect to WiFi and start TCP server.
  connect();
  server.begin();

  // Add listener callbacks for local logic.
  dino.digitalListenCallback = onDigitalListen;
  dino.analogListenCallback = onAnalogListen;

  // Use serial as the dino IO stream until we get a TCP connection.
  dino.stream = &serial;
}

void loop() {
  // Reconnect if we've lost WiFi.
  if (WiFi.status() != WL_CONNECTED) connect();

  // Allow one client at a time to be connected. Set it as the dino IO stream.
  if (!client){
    client = server.available();
    if (client) dino.stream = &client;
  }

  // Main loop of the dino library.
  dino.run();

  // End the connection when client disconnects and revert to serial IO.
  if (client && !client.connected()){
    client.stop();
    dino.stream = &serial;
  }

  // Handle OTA updates.
  #ifdef ESP8266
    ArduinoOTA.handle();
  #endif
}

// This runs every time a digital pin that dino is listening to changes value.
// p = pin number, v = current value
void onDigitalListen(byte p, byte v){
}

// This runs every time an analog pin that dino is listening to gets read.
// p = pin number, v = read value
void onAnalogListen(byte p, int v){
}
