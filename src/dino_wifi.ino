#include "Dino.h"
#ifdef ESP8266
  #include <ESP8266WiFi.h>
  #include <ESP8266mDNS.h>
  #include <WiFiUdp.h>
  #include <ArduinoOTA.h>
  #define WIFI_STATUS_LED 2
#else
  #include <SPI.h>
  #include <WiFi.h>
  #define WIFI_STATUS_LED 13
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
boolean connected = false;
long lastConnectAttempt;
int WiFiConnectTimeout = 10000;

Dino dino;
WiFiServer server(port);
WiFiClient client;

// Use the built in LED to indicate WiFi status.
void indicateWiFi(byte value) {
  pinMode(WIFI_STATUS_LED, OUTPUT);
  #ifdef ESP8266
    digitalWrite(WIFI_STATUS_LED, !value);
  #else
    digitalWrite(WIFI_STATUS_LED, value);
  #endif
}

void printWifiStatus() {
  serial.println("WiFi Connected");
  serial.print("SSID: ");
  serial.println(WiFi.SSID());
  serial.print("Signal Strength (RSSI):");
  serial.print(WiFi.RSSI());
  serial.println(" dBm");
  serial.print("IP Address: ");
  serial.println(WiFi.localIP());
  serial.print("Dino TCP Port: ");
  serial.println(port);
  indicateWiFi(true);
}

void connect(){
  #ifdef ESP8266
    WiFi.mode(WIFI_STA);
  #endif
  if (millis() - lastConnectAttempt > WiFiConnectTimeout){
    WiFi.begin(ssid, pass);
    lastConnectAttempt = millis();
  }
}

void maintainWiFi(){
  if (connected == true){
    if (WiFi.status() == WL_CONNECTED) return;
    connected = false;
    connect();
  }
  if (connected == false){
    if (WiFi.status() != WL_CONNECTED) {
      connect();
      return;
    }
    connected = true;
    printWifiStatus();
  }
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
  // Start the dino TCP server.
  server.begin();

  delay(2000);

  // Attempt initial WiFi connection.
  #ifdef debug
    indicateWiFi(false);
    serial.println();
    serial.print("Attempting to connect to SSID: ");
    serial.println(ssid);
  #endif
  connect();

  // Add listener callbacks for local logic.
  dino.digitalListenCallback = onDigitalListen;
  dino.analogListenCallback = onAnalogListen;

  // Use serial as the dino IO stream until we get a TCP connection.
  dino.stream = &serial;
}

void loop() {
  // Reconnect if we've lost WiFi.
  maintainWiFi();

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
