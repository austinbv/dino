#include <Servo.h>
Servo servo;

bool debug = false;

char request[12];
int index = 0;
char cmd[3];
char pin[3];
char val[4];
char aux[4];

String response = "";



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
      process();
      if(response != "") Serial.println(response);
    }
       
    else request[index++] = c;
  }
}



/*
 * Deal with a full request and determine function to call
 */
void process() {
  strncpy(cmd, request, 2);
  cmd[2] = '\0';
  strncpy(pin, request + 2, 2);
  pin[2] = '\0';

  if (atoi(cmd) > 90) {
    strncpy(val, request + 4, 2);
    val[2] = '\0';
    strncpy(aux, request + 6, 3);
    aux[3] = '\0';
  } else {
    strncpy(val, request + 4, 3);
    val[4] = '\0';
    strncpy(aux, request + 7, 3);
    aux[4] = '\0';
  }

  // if (debug) Serial.println(request);
  
  int p = getPin(pin);
  if (p == -1) return; // Should raise some kind of "bad pin" error.
  
  
  int cmdid = atoi(cmd);

  switch(cmdid) {
    case 0:  setMode    (p, val);       break;
    case 1:  dWrite     (p, val);       break;
    case 2:  dRead      (p);            break;
    case 3:  aWrite     (p, val);       break;
    case 4:  aRead      (p);            break;
    case 97: handlePing (p, val, aux);  break;
    case 98: handleServo(p, val, aux);  break;
    case 99: toggleDebug(val);          break;
    default:                            break;
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
void dRead(int p) { 
  pinMode(p, INPUT);
  int oraw = digitalRead(p);
  char m[7];
  sprintf(m, "%02d::%02d", p, oraw);
  response = m;
}
void aRead(int p) {
  pinMode(p, INPUT);
  int rval = analogRead(p);
  char m[8];
  sprintf(m, "%s::%03d", pin, rval);
  response = m;
}
void aWrite(int p, char *val) {
  pinMode(p, OUTPUT);
  analogWrite(p,atoi(val));
}



/*
 * Handle Ping commands
 * fire, read
 */
void handlePing(int p, char *val, char *aux) {  
  // 01(1) Fire and Read
  if (atoi(val) == 1) {
    char m[16];

    pinMode(p, OUTPUT);
    digitalWrite(p, LOW);
    delayMicroseconds(2);
    digitalWrite(p, HIGH);
    delayMicroseconds(5);
    digitalWrite(p, LOW);

    // Serial.println("ping fired");

    pinMode(p, INPUT);
    sprintf(m, "%s::read::%08d", pin, pulseIn(p, HIGH));
    response = m;

    delay(50);
  }
}



/*
 * Handle Servo commands
 * attach, detach, write, read, writeMicroseconds, attached
 */
void handleServo(int p, char *val, char *aux) {
  // 00(0) Detach
  if (atoi(val) == 0) {
    servo.detach();
    char m[12];
    sprintf(m, "%s::detached", pin);
    response = m;

  // 01(1) Attach
  } else if (atoi(val) == 1) {
    // servo.attach(p, 750, 2250);
    servo.attach(p);
    char m[12];
    sprintf(m, "%s::attached", pin);
    response = m;

  // 02(2) Write
  } else if (atoi(val) == 2) {
    // Write to servo
    servo.write(atoi(aux));
    delay(15);

  // 03(3) Read
  } else if (atoi(val) == 3) {
    int sval = servo.read();
    char m[13];
    sprintf(m, "%s::read::%03d", pin, sval);
    response = m;
  }
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
