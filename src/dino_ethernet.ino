#include "Dino.h"
#include <SPI.h>
#include <Ethernet.h>

// Define 'serial' as the serial interface we want to use.
// Defaults to Native USB port (left) on Due and Zero, or Serial otherwise.
#if defined(__SAM3X8E__) || defined(ARDUINO_SAMD_ZERO)
  #define serial SerialUSB
  // Use this for Programming USB port (right) on Due and Zero.
  //#define serial Serial
#else
  #define serial Serial
#endif

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
  // Wait for serial ready.
  serial.begin(115200);
  while(!serial);

  // Explicitly disable the SD card.
  pinMode(4,OUTPUT);
  digitalWrite(4,HIGH);

  // Start up the network connection and server.
  Ethernet.begin(mac, ip);
  server.begin();
  #ifdef debug
    printEthernetStatus();
  #endif

  // Add listener callbacks for local logic.
  dino.digitalListenCallback = onDigitalListen;
  dino.analogListenCallback = onAnalogListen;
}

void loop() {
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
}

// This runs every time a digital pin that dino is listening to changes value.
// p = pin number, v = current value
void onDigitalListen(byte p, byte v){
}

// This runs every time an analog pin that dino is listening to gets read.
// p = pin number, v = read value
void onAnalogListen(byte p, int v){
}
