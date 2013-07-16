/*
  Library for dino ruby gem.
*/

#include "Arduino.h"
#include "Dino.h"
DinoLCD dinoLCD;
DinoSerial dinoSerial;

Dino::Dino(){
  messageFragments[0] = cmdStr;
  messageFragments[1] = pinStr;
  messageFragments[2] = valStr;
  messageFragments[3] = auxMsg;
  reset();
}

void Dino::parse(char c) {
  // Handle escaped newlines.
  if (backslash) {
    if (c != '\n') append('\\');
    append(c);
    backslash = false;
  }

  // If EOL process and reset.
  else if (c == '\n') {
    append('\0');
    process();
    fragmentIndex = 0;
    charIndex = 0;
  }

  // If fragment delimiter, terminate current fragment and move to next.
  // Unless we're in the auxillary message fragment, then just append.
  else if (c == '.') {
    if (fragmentIndex < 3) {
      append('\0');
      fragmentIndex++;
      charIndex = 0;
    } else {
      append(c);
    }
  }

  // Catch backslash so we can escape the next character.
  else if (c == '\\') backslash = true;

  // Else just append the character.
  else append(c);
}

void Dino::append(char c) {
  messageFragments[fragmentIndex][charIndex++] = c;
}

void Dino::process() {
  cmd = atoi(cmdStr);
  pin = atoi(pinStr);
  val = atoi(valStr);
  response[0] = '\0';

  #ifdef debug
   Serial.print("Command - ");          Serial.println(cmdStr);
   Serial.print("Pin - ");              Serial.println(pinStr);
   Serial.print("Value - ");            Serial.println(valStr);
  #endif

  // Call the command.
  switch(cmd) {
    case 0:  setMode             ();  break;
    case 1:  dWrite              ();  break;
    case 2:  dRead               ();  break;
    case 3:  aWrite              ();  break;
    case 4:  aRead               ();  break;
    case 5:  addDigitalListener  ();  break;
    case 6:  addAnalogListener   ();  break;
    case 7:  removeListener      ();  break;
    case 8:  servoToggle         ();  break;
    case 9:  servoWrite          ();  break;
    case 10: handleLCD           ();  break;
    case 11: shiftWrite          ();  break;
    case 12: handleSerial        ();  break;
    case 90: reset               ();  break;
    case 96: setAnalogResolution ();  break;
    case 97: setAnalogDivider    ();  break;
    case 98: setHeartRate        ();  break;
    default:                          break;
  }
  
  // Write the response.
  if (response[0] != '\0') writeResponse();
  
  #ifdef debug
   Serial.print("Responded with - "); Serial.println(response);
   Serial.println();
  #endif
}



// WRITE CALLBACK
void Dino::setupWrite(void (*writeCallback)(char *str)) {
  _writeCallback = writeCallback;
}
void Dino::writeResponse() {
  _writeCallback(response);
}



// LISTNENERS
void Dino::updateListeners() {
  if (timeSince(lastUpdate) > heartRate || timeSince(lastUpdate) < 0) {
    lastUpdate = micros();
    loopCount++;
    updateDigitalListeners();
    if (loopCount % analogDivider == 0) updateAnalogListeners();
  }
}
void Dino::updateDigitalListeners() {
  for (int i = 0; i < PIN_COUNT; i++) {
    if (digitalListeners[i]) {
      pin = i;
      dRead();
      if (rval != digitalListenerValues[i]) {
        digitalListenerValues[i] = rval;
        writeResponse();
      } 
    }
  }
}
void Dino::updateAnalogListeners() {
  for (int i = 0; i < PIN_COUNT; i++) {
    if (analogListeners[i]) {
      pin = i;
      aRead();
      writeResponse();
    }
  }
}
long Dino::timeSince(long event) {
 long time = micros() - event;
 return time;
}



// API FUNCTIONS
// CMD = 00 // Pin Mode
void Dino::setMode() {
  if (val == 0) {
    removeListener();
    pinMode(pin, OUTPUT);
    #ifdef debug
      Serial.print("Set pin "); Serial.print(pin); Serial.print(" to "); Serial.println("OUTPUT mode");
    #endif
  }
  else {
    pinMode(pin, INPUT);
    #ifdef debug
      Serial.print("Set pin "); Serial.print(pin); Serial.print(" to "); Serial.println("INPTUT mode");
    #endif
  }
}

// CMD = 01 // Digital Write
void Dino::dWrite() {
  if (val == 0) {
    digitalWrite(pin, LOW);
    #ifdef debug
      Serial.print("Digital write "); Serial.print(LOW); Serial.print(" to pin "); Serial.println(pin);
    #endif
  }
  else {
    digitalWrite(pin, HIGH);
    #ifdef debug
      Serial.print("Digital write "); Serial.print(HIGH); Serial.print(" to pin "); Serial.println(pin);
    #endif
  }
}

// CMD = 02 // Digital Read
void Dino::dRead() { 
  rval = digitalRead(pin);
  sprintf(response, "%02d:%02d", pin, rval);
}

// CMD = 03 // Analog (PWM) Write
void Dino::aWrite() {
  analogWrite(pin,val);
  #ifdef debug
    Serial.print("Analog write "); Serial.print(val); Serial.print(" to pin "); Serial.println(pin);
  #endif
}

// CMD = 04 // Analog Read
void Dino::aRead() {
  rval = analogRead(pin);
  sprintf(response, "%02d:%02d", pin, rval);
}

// CMD = 05
// Listen for a digital signal on any pin.
void Dino::addDigitalListener() {
  removeListener();
  digitalListeners[pin] = true;
  digitalListenerValues[pin] = 2;
  #ifdef debug
    Serial.print("Added digital listener on pin "); Serial.println(pin);
  #endif
}

// CMD = 06
// Listen for an analog signal on analog pins only.
void Dino::addAnalogListener() {
  removeListener();
  analogListeners[pin] = true;
  #ifdef debug
    Serial.print("Added analog listener on pin "); Serial.println(pin);
  #endif
}

// CMD = 07
// Remove analog and digital listeners from any pin.
void Dino::removeListener() {
  analogListeners[pin] = false;
  digitalListeners[pin] = false;
  #ifdef debug
    Serial.print("Removed listeners on pin "); Serial.println(pin);
  #endif
}

// CMD = 08
// Attach the servo object to pin or detach it.
void Dino::servoToggle() {
  if (val == 0) {
    #ifdef debug
      Serial.print("Detaching servo"); Serial.print(" on pin "); Serial.println(pin);
    #endif
    servos[pin - SERVO_OFFSET].detach();
  }
  else {
    #ifdef debug
      Serial.print("Attaching servo"); Serial.print(" on pin "); Serial.println(pin);
    #endif
    servos[pin - SERVO_OFFSET].attach(pin);
  }
}

// CMD = 09
// Write a value to the servo object.
void Dino::servoWrite() {
  #ifdef debug
    Serial.print("Servo write "); Serial.print(val); Serial.print(" to pin "); Serial.println(pin);
  #endif
  servos[pin - SERVO_OFFSET].write(val);
}

// CMD = 10
// Write a value to the servo object.
void Dino::handleLCD() {
  #ifdef debug
    Serial.print("DinoLCD command: "); Serial.print(val); Serial.print(" with data: "); Serial.println(auxMsg);
  #endif
  dinoLCD.process(val, auxMsg);
}

// CMD = 11
// Write to a shift register.
void Dino::shiftWrite() {
  #ifdef debug
    Serial.print("Shift write :"); Serial.print(val); Serial.print(" to pin "); Serial.print(pin); Serial.print(". Clock pin: "); Serial.println(auxMsg);
  #endif
  // auxMsg should be the clock pin.
  shiftOut(pin, atoi(auxMsg), MSBFIRST, val);
}

// CMD = 12
// Control the SoftwareSerial.
void Dino::handleSerial() {
  #ifdef debug
    Serial.print("DinoSerial command: "); Serial.print(val); Serial.print(" with data: "); Serial.println(auxMsg);
  #endif
  dinoSerial.process(val, auxMsg);
}

// CMD = 90
void Dino::reset() {
  heartRate = 4000; // Default heartRate is ~4ms.
  loopCount = 0;
  analogDivider = 4; // Update analog listeners every ~16ms.
  for (int i = 0; i < PIN_COUNT; i++) digitalListeners[i] = false;
  for (int i = 0; i < PIN_COUNT; i++) digitalListenerValues[i] = 2;
  for (int i = 0; i < PIN_COUNT; i++)  analogListeners[i] = false;
  lastUpdate = micros();
  fragmentIndex = 0;
  charIndex = 0;

  #if defined(__SAM3X8E__)
    sprintf(response, "ACK:%d,%d", A0, DAC0);
  #else
    sprintf(response, "ACK:%d", A0);
  #endif
}

// CMD = 97
// Set the analog read and write resolution.
void Dino::setAnalogResolution() {
  #if defined(__SAM3X8E__)
    analogReadResolution(val);
    analogWriteResolution(val);
    #ifdef debug
      Serial.print("Analog R/W resolution set to "); Serial.println(val);
    #endif
  #endif
}

// CMD = 97
// Set the analog divider. Powers of 2 up to 128 are valid.
void Dino::setAnalogDivider() {
  analogDivider = val;
  #ifdef debug
    Serial.print("Analog divider set to "); Serial.println(analogDivider);
  #endif
}

// CMD = 98
// Set the heart rate in milliseconds. Store it in microseconds.
void Dino::setHeartRate() {
  heartRate = atoi(auxMsg);
  #ifdef debug
    Serial.print("Heart rate set to "); Serial.print(heartRate); Serial.println(" microseconds");
  #endif
}

