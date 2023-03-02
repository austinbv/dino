### Install Arduino Dependencies for Dino (IDE)

### Installing Cores

Some microcontroller platforms require board manager cores that do not come with the IDE. To install a core:
  * Open the Preferences window of the IDE, and find "Additional boards manager URLS:". Click the button next to it.
  * In the editor that opens, paste the given URL on a new line at the end (if it doesn't already exist).
  * Confirm and exit Preferences. Wait for the IDE to finish downloading indexes from the new URL.
  * Click on Tools > Board > Board Manager.
  * Search for the platform you are installing by name, and click Install, optionally selecting a version.
   
### Installing Libraries

All platforms will require libraries to be installed. To install a library do the following:
  * Click on Tools > Manage Libraries.
  * Search for the library you are installing by name, and click Install, optionally selecting a version.

### Platforms:

**Install Everything:**
  * Board Manager URLs:
    ````shell
    https://arduino.esp8266.com/stable/package_esp8266com_index.json
    https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
    ````
  * Boards (latest version unless specified):
    ````shell
    Arduino megaAVR Boards
    ESP8266 Boards
    ESP32 Boards    
    ````    
  * Libraries (latest version unless specified):
    ````shell
    Servo                       by Michael Margolis, Arduino
    Liquid Crystal              by Arduino, Adafruit
    Ethernet                    by Various
    WiFi                        by Arduino
    IRremote          @ v4.0.0  by shirriff, z3to, ArminJo
    IRremoteESP82666  @ v2.8.4  by David Conran, Sebastien Warin
    ESP32Servo                  by Kevin Harrington, John K. Bennett
    ````

**AVR-based Arduinos & Clones Only:**
  * Boards (latest version unless specified):
    ````shell
    Arduino megaAVR Boards (only for Atmega4809 / Nano Every)
    ````    
  * Libraries (latest version unless specified):
    ````shell
    Servo                       by Michael Margolis, Arduino
    Liquid Crystal              by Arduino, Adafruit
    Ethernet                    by Various
    WiFi                        by Arduino
    IRremote          @ v4.0.0  by shirriff, z3to, ArminJoß
    ````

**ESP8266 Only:**
  * Board Manager URLs:
    ````shell
    https://arduino.esp8266.com/stable/package_esp8266com_index.json
    ````
  * Boards (latest version unless specified):
    ````shell
    ESP8266 Boards
    ````    
  * Libraries (latest version unless specified):
    ````shell
    IRremoteESP82666  @ v2.8.4  by David Conran, Sebastien Warin
    ````

**ESP32 Only:**
  * Board Manager URLs:
    ````shell
    https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
    ````
  * Boards (latest version unless specified):
    ````shell
    ESP32 Boards    
    ````    
  * Libraries (latest version unless specified):
    ````shell
    IRremoteESP82666  @ v2.8.4  by David Conran, Sebastien Warin
    ESP32Servo                  by Kevin Harrington, John K. Bennett
    ````
