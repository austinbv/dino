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

//
// CMD = 19
// Write data to a WS2812 LED array. Will generalize to other types later.
//
// pin          = Microcontroller pin connected to Data In pin of the LED array.
// val          = Number of RGB or RGBW LEDS (aka pixels) in the array.
// auxMsg[0..3] = Reserved for future settings.
// auxMsg[4+]   = Raw pixel data, already in correct byte order (GRB, RGB, etc.).
//
void Dino::showLEDArray() {
  // Setup a new LED array object.
  Adafruit_NeoPixel ledArray(val, pin, NEO_GRB + NEO_KHZ800);
  ledArray.begin();

  // Copy LED data into the pixel buffer.
  // NOTE: val * 3 will have to change to val * 4 for RGBW leds.
  memcpy(ledArray.getPixels(), &auxMsg[4], val * 3);

  // I have NO idea what causes the first green LED to stay stuck on.
  // A small delay here seems like a consistent fix. ESP32 doesn't need it.
  // AVR can get away with 32us, but others need 64.
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
