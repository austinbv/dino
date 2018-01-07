/*
  Library for dino ruby gem.
*/
#include "Dino.h"

Dino::Dino(){
  messageFragments[0] = cmdStr;
  messageFragments[1] = pinStr;
  messageFragments[2] = valStr;
  messageFragments[3] = auxMsg;
  reset();
}

void Dino::parse(byte c) {
  if ((c == '\n') || (c == '\\')) {
    // If last char was a \, this \ or \n is escaped.
    if(escaping){
      append(c);
      escaping = false;
    }

    // If EOL, process and reset.
    else if (c == '\n'){
      append('\0');
      process();
      fragmentIndex = 0;
      charIndex = 0;
    }

    // Backslash is the escape character.
    else if (c == '\\') escaping = true;
  }

  // If fragment delimiter, terminate current fragment and move to next.
  // Unless we're in the auxillary message fragment, then just append.
  else if (c == '.') {
    if (fragmentIndex < 3) {
      escaping = false;
      append('\0');
      fragmentIndex++;
      charIndex = 0;
    } else {
      append(c);
    }
  }

  // Else just append the character.
  else {
    escaping = false;
    append(c);
  }
}

void Dino::append(byte c) {
  messageFragments[fragmentIndex][charIndex++] = c;
}

void Dino::process() {
  cmd = atoi((char *)cmdStr);
  pin = atoi((char *)pinStr);
  val = atoi((char *)valStr);
  response[0] = '\0';

  #ifdef debug
   Serial.print("Received - Command: "); Serial.print(cmdStr);
   Serial.print(" Pin: ");               Serial.print(pinStr);
   Serial.print(" Value: ");             Serial.print(valStr); Serial.print("\n")
  #endif

  // Call the command.
  switch(cmd) {
    // See explanation at top of DinoBugWorkaround.cpp
    case 999999: bugWorkaround   ();  break;

    // Implemented in this file.
    case 0:  setMode             ();    break;
    case 1:  dWrite              ();    break;
    case 2:  dRead               (pin); break;
    case 3:  aWrite              ();    break;
    case 4:  aRead               (pin); break;
    case 5:  addDigitalListener  ();    break;
    case 6:  addAnalogListener   ();    break;
    case 7:  removeListener      ();    break;

    // Implemented in DinoServo.cpp
    #ifdef DINO_SERVO
    case 8:  servoToggle         ();    break;
    case 9:  servoWrite          ();    break;
    #endif

    // Implemented in DinoLCD.cpp
    #ifdef DINO_LCD
    case 10: handleLCD           ();    break;
    #endif

    // Implemented in DinoSerial.cpp
    #ifdef DINO_SERIAL
    case 12: handleSerial        ();    break;
    #endif

    // Implemented in DinoDHT.cpp
    #ifdef DINO_DHT
    case 13: dhtRead             ();    break;
    #endif

    // Implemented in DinoOneWire.cpp
    #ifdef DINO_ONE_WIRE
    case 15: ds18Read            ();    break;
    #endif

    // Implemented in DinoIROut.cpp
    #ifdef DINO_IR_OUT
    case 16: irSend              ();    break;
    #endif

    // Implemented in DinoTone.cpp
    #ifdef DINO_TONE
    case 17: tone                ();    break;
    case 18: noTone              ();    break;
    #endif

    // Implemented in DinoShift.cpp
    #ifdef DINO_SHIFT
    case 21: shiftWrite          (pin, val, auxMsg[0], auxMsg[1], &auxMsg[3]); break;
    case 22: shiftRead           (pin, val, auxMsg[0], auxMsg[1], auxMsg[2]);  break;
    case 23: addShiftListener    (pin, val, auxMsg[0], auxMsg[1], auxMsg[2]);  break;
    case 24: removeShiftListener ();                                           break;
    #endif

    // Implemented in DinoSPI.cpp
    #ifdef DINO_SPI
    case 26: spiWrite         (pin, val, auxMsg[0], (uint32_t)auxMsg[1], &auxMsg[5]); break;
    case 27: spiRead          (pin, val, auxMsg[0], (uint32_t)auxMsg[1]            ); break;
    case 28: addSpiListener   (pin, val, auxMsg[0], (uint32_t)auxMsg[1]);             break;
    case 29: removeSpiListener();                                                     break;
    #endif

    // Implemented in DinoI2C.cpp
    #ifdef DINO_I2C
    case 31: i2cBegin            ();  break;
    case 32: i2cEnd              ();  break;
    case 33: i2cScan             ();  break;
    case 34: i2cWrite            ();  break;
    case 35: i2cRead             ();  break;
    #endif

    // Implemented in this file.
    case 90: reset               ();  break;
    case 95: setAnalogDivider    ();  break;
    case 96: setAnalogResolution ();  break;
    case 97: setAnalogDivider    ();  break;
    case 98: setHeartRate        ();  break;

    // Should send a "feature not implemented" message as default.
    default:                          break;
  }

  // Write the response.
  if (response[0] != '\0') writeResponse();

  #ifdef debug
   Serial.print("Responded with - "); Serial.print(response); Serial.print("\n\n");
  #endif
}


// Let the sketch pass a function that it wants us to use to write output.
// Store it as a callback and call that when we need to write.
void Dino::setupWrite(void (*writeCallback)(char *str)) {
  _writeCallback = writeCallback;
}


// Write the response variable using the callback function from the sketch.
// Always terminate with a newline.
void Dino::writeResponse() {
  _writeCallback(response);
  _writeCallback("\n");
}


// Convenience wrapper to keep track of time since last read for listeners.
long Dino::timeSince(long event) {
 long time = micros() - event;
 return time;
}


// Every heartRate microseconds, read the digital listeners and send values if changed.
// Analog listeners use a divider to run at a fraction of that frequency.
// Register listeners (Shift, I2C and SPI) all share a second divider value.
// Analog and register listeners always send values even if not changed.
// See Dino::reset for default timings.
void Dino::updateListeners() {
  if (timeSince(lastUpdate) > heartRate || timeSince(lastUpdate) < 0) {
    // Digital Listeners
    lastUpdate = micros();
    loopCount++;
    updateDigitalListeners();

    // Register Listeners
    #ifdef DINO_SHIFT
      if (loopCount % registerDivider == 0) updateShiftListeners();
    #endif
    #ifdef DINO_SPI
      if (loopCount % registerDivider == 0) updateSpiListeners();
    #endif

    // Analog Listeners
    if (loopCount % analogDivider   == 0) updateAnalogListeners();
  }
}


// CMD = 90
void Dino::reset() {
  // Disable all the types of listeners.
  clearDigitalListeners();
  clearAnalogListeners();
  #ifdef DINO_SPI
    clearSpiListeners();
  #endif
  #ifdef DINO_SHIFT
    clearShiftListeners();
  #endif

  heartRate = 4000;    // Update digital listeners every ~4ms.
  analogDivider   = 4; // Update analog listeners every ~16ms.
  registerDivider = 2; // Update register listeners every ~8ms.
  fragmentIndex = 0;
  charIndex = 0;
  loopCount = 0;
  lastUpdate = micros();

  #if defined(__SAM3X8E__)
    sprintf(response, "ACK:%d,%d", A0, DAC0);
  #else
    sprintf(response, "ACK:%d", A0);
  #endif
}


// CMD = 95
// Set the register read divider. Powers of 2 up to 128 are valid.
void Dino::setRegisterDivider() {
  registerDivider = val;
  #ifdef debug
    Serial.print("Called Dino::setRegisterDivider()\n");
  #endif
}


// CMD = 96
// Set the analog read and write resolution.
void Dino::setAnalogResolution() {
  #if defined(__SAM3X8E__)
    analogReadResolution(val);
    analogWriteResolution(val);
  #endif
  #ifdef debug
    Serial.print("Called Dino::setAnalogResolution()\n");
  #endif
}


// CMD = 97
// Set the analog divider. Powers of 2 up to 128 are valid.
void Dino::setAnalogDivider() {
  analogDivider = val;
  #ifdef debug
    Serial.print("Called Dino::setAnalogDivider()\n");
  #endif
}


// CMD = 98
// Set the heart rate in milliseconds. Store it in microseconds.
void Dino::setHeartRate() {
  heartRate = atoi((char *)auxMsg);
  #ifdef debug
    Serial.print("Called Dino::setHeartRate()\n");
  #endif
}
