/*
  Library for dino ruby gem.
*/
#include "Dino.h"

Dino::Dino(){
  messageFragments[0] = cmdStr;
  messageFragments[1] = pinStr;
  messageFragments[2] = valStr;
  messageFragments[3] = auxMsg;
  resetState();
}


void Dino::acknowledge() {
  stream->print("RCV:");
  stream->print(rcvBytes);
  stream->print("\n");
  rcvBytes = 0;
}

void Dino::run(){
  boolean gotByte = false;

  while(stream->available() > 0) {
    gotByte = true;
    rcvBytes ++;
    parse(stream->read());

    // Acknowledge when we've received as many bytes as the serial input buffer
    if (rcvBytes == rcvThreshold) acknowledge();
  }
  if (gotByte) lastRcv = micros();

  // Also acknowledge when the last byte received goes outside the receive window.
  if ((rcvBytes > 0) && ((micros() - lastRcv) > rcvWindow)) acknowledge();

  // Run dino's listeners.
  updateListeners();
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
    case 7:  setListener         ();    break;

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
    case 23: addShiftListener    ();  break;
    case 24: removeShiftListener ();  break;
    #endif

    // Implemented in DinoSPI.cpp
    #ifdef DINO_SPI
    case 26: spiTransfer      (pin, auxMsg[0], auxMsg[1], auxMsg[2], (uint32_t)auxMsg[3], &auxMsg[7]); break;
    case 27: addSpiListener   ();  break;
    case 28: removeSpiListener();  break;
    #endif

    // Implemented in DinoI2C.cpp
    #ifdef DINO_I2C
    case 31: i2cBegin            ();  break;
    case 32: i2cEnd              ();  break;
    case 33: i2cScan             ();  break;
    case 34: i2cWrite            ();  break;
    case 35: i2cRead             ();  break;
    #endif

    // Implemented in DinoOneWire.cpp
    #ifdef DINO_ONE_WIRE
    case 41: owReset             ();  break;
    case 42: owSearch            ();  break;
    case 43: owWrite             ();  break;
    case 44: owRead              ();  break;
    #endif

    // Implemented in this file.
    case 90: reset               ();  break;
    case 95: setRegisterDivider  ();  break;
    case 96: setAnalogResolution ();  break;

    // Should send a "feature not implemented" message as default.
    default:                          break;
  }

  #ifdef debug
   Serial.print("Responded with - "); Serial.print(response); Serial.print("\n\n");
  #endif
}


// Expect the sketch to pass a pointer to something that inherits from Stream.
// Store it and call ->print, ->write, etc on it to send data.
void Dino::setOutputStream(Stream* callback){
  stream = callback;
}

//
// Every 1000 microseconds count a tick and call the listeners.
// Each core listener has its own divider, so it can read every
// 1, 2, 4, 8, 16, 32, 64 or 128 ticks, independent of the others.
//
// Register listeners are still on a global divider for now.
// Analog and register listeners always send values even if not changed.
// Digital listeners only send values on change.
//
void Dino::updateListeners() {
  unsigned long now = micros();
  if ((now - lastTick) > 1000) {
    lastTick = now;
    tickCount++;

    updateCoreListeners(tickCount);

    // Register Listeners
    #ifdef DINO_SHIFT
      if (tickCount % registerDivider == 0) updateShiftListeners();
    #endif
    #ifdef DINO_SPI
      if (tickCount % registerDivider == 0) updateSpiListeners();
    #endif
  }
}


// CMD = 90
void Dino::reset() {
  resetState();

  // Reset this so we never send RCV: along with ACK:
  rcvBytes = 0;

  stream->print("ACK:");
  stream->print(A0);
  #if defined(__SAM3X8E__)
    stream->print(',');
    stream->print(DAC0);
  #endif
  stream->print('\n');
}


void Dino::resetState() {
  clearCoreListeners();
  lastActiveListener = 0;
  #ifdef DINO_SPI
    clearSpiListeners();
  #endif
  #ifdef DINO_SHIFT
    clearShiftListeners();
  #endif
  registerDivider = 8; // Update register listeners every ~8ms.
  fragmentIndex = 0;
  charIndex = 0;
  tickCount = 0;
  lastTick = micros();
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
