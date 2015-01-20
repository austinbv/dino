/*
  Library for smalrubot ruby gem.
*/

#include "Arduino.h"
#include "Smalrubot.h"

Smalrubot::Smalrubot(){
  reset();
}

void Smalrubot::parse(char c) {
  if (c == '!') index = 0;        // Reset request
  else if (c == '.') process();   // End request and process
  else request[index++] = c;      // Append to request
}

void Smalrubot::process() {
  response[0] = '\0';

  // Parse the request.
  strncpy(cmdStr, request, 2);      cmdStr[2] =  '\0';
  strncpy(pinStr, request + 2, 2);  pinStr[2] =  '\0';
  strncpy(valStr, request + 4, 3);  valStr[3] =  '\0';
  cmd = atoi(cmdStr);
  pin = atoi(pinStr);
  val = atoi(valStr);

  #ifdef debug
   Serial.print("Received request - "); Serial.println(request);
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
    case 90: reset               ();  break;
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
void Smalrubot::setupWrite(void (*writeCallback)(char *str)) {
  _writeCallback = writeCallback;
}
void Smalrubot::writeResponse() {
  _writeCallback(response);
}



// LISTNENERS
void Smalrubot::updateListeners() {
  if (timeSince(lastUpdate) > heartRate || timeSince(lastUpdate) < 0) {
    lastUpdate = micros();
    loopCount++;
    updateDigitalListeners();
    if (loopCount % analogDivider == 0) updateAnalogListeners();
  }
}
void Smalrubot::updateDigitalListeners() {
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
void Smalrubot::updateAnalogListeners() {
  for (int i = 0; i < PIN_COUNT; i++) {
    if (analogListeners[i]) {
      pin = i;
      aRead();
      writeResponse();
    }
  }
}
long Smalrubot::timeSince(long event) {
 long time = micros() - event;
 return time;
}



// API FUNCTIONS
// CMD = 00 // Pin Mode
void Smalrubot::setMode() {
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
void Smalrubot::dWrite() {
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
void Smalrubot::dRead() { 
  rval = digitalRead(pin);
  sprintf(response, "%02d:%02d", pin, rval);
}

// CMD = 03 // Analog (PWM) Write
void Smalrubot::aWrite() {
  analogWrite(pin,val);
  #ifdef debug
    Serial.print("Analog write "); Serial.print(val); Serial.print(" to pin "); Serial.println(pin);
  #endif
}

// CMD = 04 // Analog Read
void Smalrubot::aRead() {
  rval = analogRead(pin);
  sprintf(response, "%02d:%02d", pin, rval);
}

// CMD = 05
// Listen for a digital signal on any pin.
void Smalrubot::addDigitalListener() {
  removeListener();
  digitalListeners[pin] = true;
  digitalListenerValues[pin] = 2;
  #ifdef debug
    Serial.print("Added digital listener on pin "); Serial.println(pin);
  #endif
}

// CMD = 06
// Listen for an analog signal on analog pins only.
void Smalrubot::addAnalogListener() {
  removeListener();
  analogListeners[pin] = true;
  #ifdef debug
    Serial.print("Added analog listener on pin "); Serial.println(pin);
  #endif
}

// CMD = 07
// Remove analog and digital listeners from any pin.
void Smalrubot::removeListener() {
  analogListeners[pin] = false;
  digitalListeners[pin] = false;
  #ifdef debug
    Serial.print("Removed listeners on pin "); Serial.println(pin);
  #endif
}

// CMD = 08
// Attach the servo object to pin or detach it.
void Smalrubot::servoToggle() {
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
void Smalrubot::servoWrite() {
  #ifdef debug
    Serial.print("Servo write "); Serial.print(val); Serial.print(" to pin "); Serial.println(pin);
  #endif
  servos[pin - SERVO_OFFSET].write(val);
}

// CMD = 90
void Smalrubot::reset() {
  heartRate = 4000; // Default heartRate is ~4ms.
  loopCount = 0;
  analogDivider = 4; // Update analog listeners every ~16ms.
  for (int i = 0; i < PIN_COUNT; i++) digitalListeners[i] = false;
  for (int i = 0; i < PIN_COUNT; i++) digitalListenerValues[i] = 2;
  for (int i = 0; i < PIN_COUNT; i++)  analogListeners[i] = false;
  lastUpdate = micros();
  index = 0;
  #ifdef debug
    Serial.println("Reset the board to defaults.");
  #endif
  sprintf(response, "ACK:%02d", A0);
}

// CMD = 97
// Set the analog divider. Powers of 2 up to 128 are valid.
void Smalrubot::setAnalogDivider() {
  analogDivider = val;
  #ifdef debug
    Serial.print("Analog divider set to "); Serial.println(analogDivider);
  #endif
}

// CMD = 98
// Set the heart rate in milliseconds. Store it in microseconds.
void Smalrubot::setHeartRate() {
  int rate = val;
  heartRate = (rate * 1000);
  #ifdef debug
    Serial.print("Heart rate set to "); Serial.print(heartRate); Serial.println(" microseconds");
  #endif
}

