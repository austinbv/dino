#include "Dino.h"
#include <SPI.h>
#include <Ethernet.h>

// Configure your MAC address, IP address, and HTTP port here.
byte mac[] = { 
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
IPAddress ip(192,168,0,77);
int port = 80;

EthernetServer server(port);
Dino dino;
String url = "";
char request[8];
String response = "";

void setup() {
  // Start up the network connection and server.
  Ethernet.begin(mac, ip);
  server.begin();

  // Start serial for debugging.
  Serial.begin(115200);
  Serial.print("Dino HTTP client started at ");
  Serial.print(Ethernet.localIP());
  Serial.print(" on port ");
  Serial.println(port);
}

void loop() {
  // Listen for connections.
  EthernetClient client = server.available();

  // Handle a connection.
  if (client) {
    url = "";
    response = "";
    while (client.connected()) {
      if (client.available()) {
        char c = client.read();
        url += c;

        // Once the first line of the request is received, process it. We don't need the rest...for now.
        if (c == '\n') {

          // Figure out where the command (passed as a parameter) starts and ends and extract it.
          int requestStart = url.indexOf('!');
          int requestEnd = url.indexOf('.', requestStart);

          // Convert it into a char array and pass it to the Dino library.
          url.substring(requestStart + 1, requestEnd).toCharArray(request, 8);
          Serial.println(request);
          dino.process(request, &response);

          // Return an HTTP response.
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/plain");
          client.println();
          client.println(response);
          break;
        }
      }
    }
    client.stop();
  }
}

