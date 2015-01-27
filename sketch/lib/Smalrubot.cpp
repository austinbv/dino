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

  processCommand();
  
  // Write the response.
  if (response[0] != '\0') writeResponse();
  
  #ifdef debug
   Serial.print("Responded with - "); Serial.println(response);
   Serial.println();
  #endif
}


void Smalrubot::processCommand() {
  // Call the command.
  switch(cmd) {
    case 0:  setMode             ();  break;
    case 1:  dWrite              ();  break;
    case 2:  dRead               ();  break;
    case 3:  aWrite              ();  break;
    case 4:  aRead               ();  break;
    case 8:  servoToggle         ();  break;
    case 9:  servoWrite          ();  break;
    case 90: reset               ();  break;
    default:                          break;
  }
}


// WRITE CALLBACK
void Smalrubot::setupWrite(void (*writeCallback)(char *str)) {
  _writeCallback = writeCallback;
}
void Smalrubot::writeResponse() {
  _writeCallback(response);
}






// API FUNCTIONS
// CMD = 00 // Pin Mode
void Smalrubot::setMode() {
  if (val == 0) {
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
  #ifdef debug
    Serial.println("Reset the board to defaults.");
  #endif
  sprintf(response, "ACK:%02d", A0);
}
