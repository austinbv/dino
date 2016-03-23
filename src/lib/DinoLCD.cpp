#include "Arduino.h"
#include "DinoLCD.h"

LiquidCrystal lcd(12,11,5,4,3,2);

DinoLCD::DinoLCD(){
}

int *DinoLCD::parse(char *aux){
  int *values = new int[11];
  char *str;
  int index = 0;
  while ((str = strsep(&aux, ",")) != NULL) {
    values[index] = atoi(str);
    index++;
  }
  parseSize = index;
  return values;
}

void DinoLCD::process(int cmd, char *message) {
  switch(cmd) {
    case 0:  setPins(message);           break;
    case 1:  beginLCD(message);          break;
    case 2:  lcd.clear();                break;
    case 3:  lcd.home();                 break;
    case 4:  setLCDCursor(message);      break;
    case 5:  lcd.print(message);         break;
    case 6:  lcd.cursor();               break;
    case 7:  lcd.noCursor();             break;
    case 8:  lcd.blink();                break;
    case 9:  lcd.noBlink();              break;
    case 10: lcd.display();              break;
    case 11: lcd.noDisplay();            break;
    case 12: lcd.scrollDisplayLeft();    break;
    case 13: lcd.scrollDisplayRight();   break;
    case 14: lcd.autoscroll();           break;
    case 15: lcd.noAutoscroll();         break;
    case 16: lcd.leftToRight();          break;
    case 17: lcd.rightToLeft();          break;
    default:                             break;
  }
}

void DinoLCD::setPins(char *aux) {
  int *pins = parse(aux);
  if(parseSize > 6) {
    // 8 bits mode
    LiquidCrystal newLCD(pins[0],pins[1],pins[2],pins[3],pins[4],pins[5],
                         pins[6], pins[7], pins[8], pins[9]);
    lcd = newLCD;
  }
  else {
    // 4 bits mode
    LiquidCrystal newLCD(pins[0],pins[1],pins[2],pins[3],pins[4],pins[5]);
    lcd = newLCD;
  }
}

void DinoLCD::beginLCD(char *aux) {
  int *values = parse(aux);
  lcd.begin(values[0], values[1]);
}

void DinoLCD::setLCDCursor(char *aux) {
  int *values = parse(aux);
  lcd.setCursor(values[0], values[1]);
}
