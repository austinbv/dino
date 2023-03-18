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

**Note:** Always install the latest version of a package unless its version number is specified

**Install Everything:**
  * Board Manager URLs:
    ````shell
    https://arduino.esp8266.com/stable/package_esp8266com_index.json
    https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
    https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json
    ````
  * Boards:
    ````shell
    Arduino megaAVR Boards
    Arduino SAM Boards (32-bits ARM Cortex-M3)
    Arduino SAMD Boards (32-bits ARM Cortex-M0+)
    ESP8266 Boards
    ESP32 Boards    
    ````    
  * Libraries:
    ````shell
    Servo                      by Michael Margolis, Arduino
    Ethernet                   by Various
    WiFi                       by Arduino
    IRremote         @ v4.0.0  by shirriff, z3to, ArminJo
    IRremoteESP82666 @ v2.8.4  by David Conran, Sebastien Warin
    ESP32Servo                 by Kevin Harrington, John K. Bennett
    ````

**AVR-based Arduinos & Clones Only:**
  * Boards:
    ````shell
    Arduino megaAVR Boards (only for Atmega4809 / Nano Every)
    ````    
  * Libraries:
    ````shell
    Servo                      by Michael Margolis, Arduino
    Ethernet                   by Various
    WiFi                       by Arduino
    IRremote         @ v4.0.0  by shirriff, z3to, ArminJo
    ````
    
**ARM-based Arduinos & Clones Only:**
  * Boards:
    ````shell
    Arduino SAM Boards (32-bits ARM Cortex-M3)
    Arduino SAMD Boards (32-bits ARM Cortex-M0+)
    ````    
  * Libraries:
    ````shell
    Servo                      by Michael Margolis, Arduino
    Ethernet                   by Various
    WiFi                       by Arduino
    IRremote         @ v4.0.0  by shirriff, z3to, ArminJo
    ````

**ESP8266 Only:**
  * Board Manager URLs:
    ````shell
    https://arduino.esp8266.com/stable/package_esp8266com_index.json
    ````
  * Boards:
    ````shell
    ESP8266 Boards
    ````    
  * Libraries:
    ````shell
    IRremoteESP82666 @ v2.8.4  by David Conran, Sebastien Warin
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
    IRremoteESP82666 @ v2.8.4  by David Conran, Sebastien Warin
    ESP32Servo                 by Kevin Harrington, John K. Bennett
    ````
    
**RP2040 Only:**
  * Board Manager URLs:
    ````shell
    https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json
    ````
  * Boards:
    ````shell
    Raspberry Pi Pico/RP2040   
    ````    
  * Libraries:
    ````shell
    IRremote         @ v4.0.0  by shirriff, z3to, ArminJo
    ````
