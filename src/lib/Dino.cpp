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

void Dino::rxNotify() {
  stream->print("Rx");
  stream->print(rxBytes);
  stream->print("\n");
  rxBytes = 0;
}

void Dino::sendHalt() {
  stream->print("Hlt");
  stream->print("\n");
}

// CMD = 92
// Expose this for diagnostics and testing.
void Dino::sendReady() {
  stream->print("Rdy");
  stream->print("\n");
}

void Dino::run(){
  while(stream->available() > 0) {
    rxBytes ++;
    parse(stream->read());

    // Acknowledge when we've received half as many bytes as the serial buffer.
    if (rxBytes >= rxNotifyLimit) rxNotify();
  }

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
      if ((fragmentIndex > 0) || (charIndex > 1)) process();
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
  messageFragments[fragmentIndex][charIndex] = c;
  charIndex++;
}

void Dino::process() {
  cmd = atoi((char *)cmdStr);
  pin = atoi((char *)pinStr);
  val = atoi((char *)valStr);

  #ifdef debug
    if (cmd != 90) {
      Serial.print("cmd:");   Serial.print(cmd);
      Serial.print(", pin:"); Serial.print(pin);
      Serial.print(", val:"); Serial.println(val);
    }
  #endif

  // Call the command.
  switch(cmd) {
    // Implemented in DinoCoreIO.cpp
    case 0:  setMode             (pin, val);        break;
    case 1:  dWrite              (pin, val, false); break;
    case 2:  dRead               (pin);             break;
    case 3:  pwmWrite            (pin, val, false); break;
    case 4:  dacWrite            (pin, val, false); break;
    case 5:  aRead               (pin);             break;
    case 6:  setListener         (pin, val, auxMsg[0], auxMsg[1], false); break;

  	#ifdef EEPROM_PRESENT
    // Implemented in DinoEEPROM.cpp
    case 7:  eepromRead          ();    break;
    case 8:  eepromWrite         ();    break;
	  #endif

    // Implemented in DinoPulseInput.cpp
    case 9: pulseRead           ();    break;

    // Implemented in DinoServo.cpp
    #ifdef DINO_SERVO
    case 10:  servoToggle         ();    break;
    case 11:  servoWrite          ();    break;
    #endif

    // Implemented in DinoSerial.cpp
    #ifdef DINO_SERIAL
    case 12: handleSerial        ();    break;
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

    // Implemented in DinoAddressableLED.cppp
    #ifdef DINO_LED_ARRAY
    case 19: showLEDArray    ();   //cmd = 19
    #endif

    // Implemented in DinoShift.cpp
    #ifdef DINO_SHIFT
    case 21: shiftWrite          (pin, val, auxMsg[0], auxMsg[1], auxMsg[2], &auxMsg[3]); break;
    case 22: shiftRead           (pin, val, auxMsg[0], auxMsg[1], auxMsg[2]);             break;
    case 23: addShiftListener    ();  break;
    case 24: removeShiftListener ();  break;
    #endif

    // Implemented in DinoSPI.cpp
    #ifdef DINO_SPI
    case 26: spiTransfer      (pin, auxMsg[0], auxMsg[1], auxMsg[2], *reinterpret_cast<uint32_t*>(auxMsg + 3), &auxMsg[7]); break;
    case 27: addSpiListener   ();  break;
    case 28: removeSpiListener();  break;
    #endif

    // Implemented in DinoI2C.cpp
    #ifdef DINO_I2C
    case 33: i2cSearch           ();  break;
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
    case 90: handshake                ();  break;
    case 91: resetState               ();  break;
    case 92: sendReady                ();  break;
    case 95: setRegisterDivider       ();  break;
    case 96: setAnalogWriteResolution ();  break;
    case 97: setAnalogReadResolution  ();  break;
    case 99: microDelay(*reinterpret_cast<uint16_t*>(auxMsg)); break;

    // Should send a "feature not implemented" message as default.
    default:                          break;
  }
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
  currentTime = micros();
  timeDiff = currentTime - lastTime;
  
  if (timeDiff > 999) {
    // Add a tick for every 1000us passed
    tickCount = tickCount + (timeDiff / 1000);
      
    // lastTime for next run is currentTime offset by remainder.
    lastTime = currentTime - (timeDiff % 1000);

    updateCoreListeners();

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
void Dino::handshake() {
  resetState();

  // Reset this so we never send Rx along with ACK:
  rxBytes = 0;
  
  // First value is aux size in bytes.
  stream->print("ACK:");
  stream->print(AUX_SIZE);
  
  // Second is EEPROM size in bytes. None on Due or Zero.
  stream->print(',');
  #if defined(EEPROM_EMULATED)
  	stream->print(EMULATED_EEPROM_LENGTH);
  #elif defined(EEPROM_PRESENT)
	  stream->print(EEPROM.length());
  #else
    stream->print('0');
  #endif
  
  // Third is A0. Ignore for ESP32. Pins aren't in order.
  #if !defined(ESP32)
    stream->print(',');  
    stream->print(A0);
  #endif

  // 4th is DAC0 if available. Ignore for ESP32. Also not in order.
  #if defined(__SAM3X8E__) || defined(__SAMD21G18A__)
    stream->print(',');
    stream->print(DAC0);
  #endif
  
  // End
  stream->print('\n');
}

// CMD = 91
void Dino::resetState() {
  clearCoreListeners();
  #ifdef ESP32
    clearLedcChannels();
  #endif
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
  lastTime = micros();
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
// Set the analog write resolution.
void Dino::setAnalogWriteResolution() {
  #ifdef WRITE_RESOLUTION_SETTER
    analogWriteResolution(val);
  #endif
}

// CMD = 97
// Set the analog read resolution.
void Dino::setAnalogReadResolution() {
  #ifdef READ_RESOLUTION_SETTER
    analogReadResolution(val);
  #endif
}

// CMD = 99
// Use a different blocking microsecond delay on different platforms.
void Dino::microDelay(uint32_t microseconds){
  #if defined(ESP32)
    ets_delay_us(microseconds);
  #else
    delayMicroseconds(microseconds);
  #endif
}
