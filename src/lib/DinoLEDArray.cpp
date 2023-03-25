//
// Write addressable LEDs using standard Arduino libraries.
//
#include "Dino.h"
#ifdef DINO_LED_ARRAY

//
// WS2812 / NeoPixel support using Adafruit library from:
// https://github.com/adafruit/Adafruit_NeoPixel
//
# ifdef DINO_LED_WS2812
  #include <Adafruit_NeoPixel.h>
#endif

// CMD = 19
// Will become a general function later. Just WS2812 for now.
void Dino::showLEDArray() {
  // pin is the output pin, connected to Data In on the WS2812.
  // val is the number of pixels in the array.
  Adafruit_NeoPixel ledArray(val, pin, NEO_GRB + NEO_KHZ800);
  ledArray.begin();

  // LED data starts at auxMsg[4]. 0..3 left free for future config.
  // Copy LED data into the pixel buffer.
  // NOTE: val * 3 will have to change to val * 4 for RGBW leds.
  memcpy(ledArray.getPixels(), &auxMsg[4], val * 3);

  // I have NO idea what causes the first green value to stay stuck on 255,
  // but a small delay here seems like a consistent fix. Different
  // values for each platform. ESP32 doesn't seem to need it.
  #if defined(ESP8266) || defined(__SAMD21G18A__) || defined(__SAM3X8E__)
    delayMicroseconds(64);
  #endif
  #ifdef __AVR__
    delayMicroseconds(32);
  #endif

  // Write the pixel buffer to the array.
  ledArray.show();

  // Tell the computer to resume sending data.
  sendReady();
}
#endif
