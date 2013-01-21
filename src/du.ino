char request[7];
int index = 0;
String response = "";
bool debug = false;

void setup() {
  Serial.begin(115200);
}

void loop() {
  while(Serial.available() > 0) {
    char c = Serial.read();

    // Reset the request and response when the beginning delimiter is received.
    if (c == '!') {
      index = 0;
      response = "";
    } 
    
    // Catch the request's ending delimiter and process the request.
    else if (c == '.') {
      process(request);
      if(response != "") Serial.println(response);
    }
       
    else request[index++] = c;
  }
}



/*
 * Deal with a full request and determine function to call
 */
void process(char *request) {
   char cmd[3];  strncpy(cmd, request, 2);      cmd[2] = '\0';
   char pin[3];  strncpy(pin, request + 2, 2);  pin[2] = '\0';
   char val[4];  strncpy(val, request + 4, 3);  val[3] = '\0';
  
  // if (debug) Serial.println(request);  
  int rawPin = getPin(pin);
  if (rawPin == -1) return; // Should raise some kind of "bad pin" error.
 
  int cmdid = atoi(cmd);
  switch(cmdid) {
    case 0:  setMode    (rawPin, val);             break;
    case 1:  dWrite     (rawPin, val);             break;
    case 2:  dRead      (rawPin, &response);       break;
    case 3:  aWrite     (rawPin, val);             break;
    case 4:  aRead      (rawPin, &response, pin);  break;
    case 99: toggleDebug(val);                     break;
    default:                                       break;
  }
}



/*
 * Set pin mode
 */
void setMode(int p, char *val) {
  if (atoi(val) == 0) {
    pinMode(p, OUTPUT);
  } else {
    pinMode(p, INPUT);
  }
}



/*
 *  Basic reads and writes
 */
void dWrite(int p, char *val) {
  pinMode(p, OUTPUT);
  if (atoi(val) == 0) {
    digitalWrite(p, LOW);
  } else {
    digitalWrite(p, HIGH);
  }
}
void dRead(int p, String *response) { 
  pinMode(p, INPUT);
  int oraw = digitalRead(p);
  char m[7];
  sprintf(m, "%02d::%02d", p, oraw);
  *response = m;
}
void aWrite(int p, char *val) {
  pinMode(p, OUTPUT);
  analogWrite(p,atoi(val));
}
void aRead(int p, String *response, char *pin) {
  pinMode(p, INPUT);
  int rval = analogRead(p);
  char m[8];
  sprintf(m, "%s::%03d", pin, rval);
  *response = m;
}




/*
 * Toggle debug mode
 */
void toggleDebug(char *val) {
  if (atoi(val) == 0) {
    debug = false;
    response = "goodbye";
  } else {
    debug = true;
    response = "hello";
  }
}



/*
 * Converts to A0-A5, and returns -1 on error
 */
int getPin(char *pin) {
  int ret = -1;
  if(pin[0] == 'A' || pin[0] == 'a') {
    switch(pin[1]) {
      case '0':  ret = A0; break;
      case '1':  ret = A1; break;
      case '2':  ret = A2; break;
      case '3':  ret = A3; break;
      case '4':  ret = A4; break;
      case '5':  ret = A5; break;
      default:             break;
    }
  } else {
    ret = atoi(pin);
    if(ret == 0 && (pin[0] != '0' || pin[1] != '0')) {
      ret = -1;
    }
  }
  return ret;
}
