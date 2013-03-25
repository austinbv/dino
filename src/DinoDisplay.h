/*
  DinoDisplay.h - LCD Display handling for Dino.
  Created by Herman Moreno, March 24, 2013.
  Released into the public domain.
*/

#include <Arduino.h>
#include <LiquidCrystal.h>

void beginLCD(LiquidCrystal &lcd, char *message) {
  char cols[3];
  char rows[3];
  strncpy(cols, message + 4, 2);
  strncpy(rows, message + 6, 2);
  cols[2] = '\0';
  rows[2] = '\0';
  lcd.begin(atoi(cols), atoi(rows));
}

void setLCDCursor(LiquidCrystal &lcd, char *message) {
  char col[3];
  char row[3];
  strncpy(col, message + 4, 2);
  strncpy(row, message + 6, 2);
  col[2] = '\0';
  row[2] = '\0';
  lcd.setCursor(atoi(col), atoi(row));
}

void writeLCD(LiquidCrystal &lcd, char *message) {
  char val[4];
  strncpy(val, message + 4, 3);
  val[3] = '\0';
  lcd.write(atoi(val));
}

void handleDisplay(LiquidCrystal &lcd, char *message) {
  char cmd[2];
  strncpy(cmd, message + 2, 2);
  switch(atoi(cmd)) {
    case 1:  beginLCD(lcd, message);     break;
    case 2:  lcd.clear();                break;
    case 3:  lcd.home();                 break;
    case 4:  setLCDCursor(lcd, message); break;
    case 5:  writeLCD(lcd, message);     break;
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
