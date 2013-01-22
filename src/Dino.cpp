#include "Arduino.h"
#include "Dino.h"

Dino::Dino(){
  debug: false;
}

// Deal with a single request.
void Dino::process(char *request, String *loopResponse) {
  
  // Reset the instance variable.
  response = "";
  
  // Parse the request.
  strncpy(cmd, request, 2);      cmd[2] = '\0';
  strncpy(pin, request + 2, 2);  pin[2] = '\0';
  strncpy(val, request + 4, 3);  val[3] = '\0';
  
  // if (debug) Serial.println(request);  
  convertPin();
  if (intPin == -1) return; // Should raise some kind of "bad pin" error.
  
  int cmdid = atoi(cmd);
  switch(cmdid) {
    case 0:  setMode    ();  break;
    case 1:  dWrite     ();  break;
    case 2:  dRead      ();  break;
    case 3:  aWrite     ();  break;
    case 4:  aRead      ();  break;
    case 99: toggleDebug();  break;
    default:                 break;
  }
  
  // Write the instance variable back to the global for the main loop to catch.
  *loopResponse = response;
}



// Set pin mode.
void Dino::setMode() {
  if (atoi(val) == 0) {
    pinMode(intPin, OUTPUT);
  } else {
    pinMode(intPin, INPUT);
  }
}



// Basic reads and writes.
void Dino::dWrite() {
  pinMode(intPin, OUTPUT);
  if (atoi(val) == 0) {
    digitalWrite(intPin, LOW);
  } else {
    digitalWrite(intPin, HIGH);
  }
}
void Dino::dRead() { 
  pinMode(intPin, INPUT);
  int oraw = digitalRead(intPin);
  char m[7];
  sprintf(m, "%02d::%02d", intPin, oraw);
  response = m;
}
void Dino::aWrite() {
  pinMode(intPin, OUTPUT);
  analogWrite(intPin,atoi(val));
}
void Dino::aRead() {
  pinMode(intPin, INPUT);
  int rval = analogRead(intPin);
  char m[8];
  sprintf(m, "%s::%03d", pin, rval); // Send response with 'A0' formatting, not integer, so pin and not intPin.
  response = m;
}



// Toggle debug mode
void Dino::toggleDebug() {
  if (atoi(val) == 0) {
    debug = false;
    response = "Debugging disabled.";
  } else {
    debug = true;
    response = "Debugging enabled.";
  }
}



// Converts to A0-A5, and returns -1 on error.
void Dino::convertPin() {
  intPin = -1;
  if(pin[0] == 'A' || pin[0] == 'a') {
    switch(pin[1]) {
      case '0':  intPin = A0; break;
      case '1':  intPin = A1; break;
      case '2':  intPin = A2; break;
      case '3':  intPin = A3; break;
      case '4':  intPin = A4; break;
      case '5':  intPin = A5; break;
      default:                break;
    }
  } else {
    intPin = atoi(pin);
    if(intPin == 0 && (pin[0] != '0' || pin[1] != '0')) {
      intPin = -1;
    }
  }
}

