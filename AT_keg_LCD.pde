#include <Arial14.h>
#include <ks0108.h>
#include <ks0108_Arduino.h>
#include <ks0108_Teensy.h>
#include <SystemFont5x7.h>

#include <ks0108.h>
#include "Arial14.h"         // proportional font
#include "SystemFont5x7.h"   // system font
#include <inttypes.h>
#include <avr/pgmspace.h>

#include <OneWire.h>
#include <DallasTemperature.h>

#ifndef ATIcon_H
#define ATIcon_H
static uint8_t ATIcon[] PROGMEM = {
  42, // width
  42, // height
0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f, 0x7f, 0x7f, 0x7f, 0x3f, 
0x3f, 0x3f, 0x1f, 0x1f, 0x0f, 0x0f, 0x0f, 0x1f, 0x1f, 0x1f, 0x3f, 0x7f, 0xff, 0xff, 0xff, 0xff, 
0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfc, 0xf8, 0xf0, 0xe0, 0xa0, 
0xe0, 0x80, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x03, 0x07, 
0x0f, 0x1f, 0x3f, 0x7f, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 
0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 
0xff, 0xff, 0xff, 0xfd, 0xff, 0xfe, 0xfc, 0xf0, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x03, 0x07, 0x0f, 
0xff, 0xff, 0xff, 0x7f, 0x3f, 0x3f, 0x3f, 0x1f, 0x1f, 0x0f, 0x0f, 0x0f, 0x07, 0x07, 0x07, 0x03, 
0x03, 0x03, 0x03, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};
#endif 

#define ONE_WIRE_BUS 10
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

unsigned long startMillis;
unsigned int loops = 0;
unsigned int iter = 0;
unsigned int state = 1;

char keg1_infoa[20] = " Belgian";
char keg1_infob[20] = " Golden";
char keg1_infoc[20] = " ";
char keg1_infod[20] = " ";
char keg1_infoe[20] = "";
char keg2_infoa[20] = " Lefthand";
char keg2_infob[20] = " Sawtooth";
char keg2_infoc[20] = " ";
char keg2_infod[20] = "";
char keg2_infoe[20] = "";

unsigned int keg1_size=332;
unsigned int keg2_size=332;
unsigned int keg1_cur=222;
unsigned int keg2_cur=222;
 
DeviceAddress termAmb, termOne, termTwo;

void setup(){
 
    Serial.begin(9600);
    Serial.println("Boot");
  delay(500);                // allow time for LCD to reset
  GLCD.Init(NON_INVERTED);   // initialise the library, non inverted writes pixels onto a clear screen
  GLCD.ClearScreen();  
  GLCD.DrawBitmap(ATIcon, 42,0, BLACK); //draw the bitmap at the given x,y position
  GLCD.SelectFont(Arial_14); // you can also make your own fonts, see playground for details   
  GLCD.GotoXY(20, 45);
  GLCD.Puts("AppliedTrust");
  
  //GLCD.SelectFont(System5x7); 
  //GLCD.GotoXY(2, 20);
  //GLCD.Puts("Searching...");
  sensors.begin();
  //GLCD.GotoXY(14, 20);
  //GLCD.Puts("  ...found ");
  //GLCD.PrintNumber(sensors.getDeviceCount()); 
  //GLCD.Puts("sensors.");
  
  GLCD.SelectFont(System5x7); 
  countdown(3);
  print_welcome();   delay(1000);
}

void countdown(int count){
    while(count--){  // do countdown  
     GLCD.CursorTo(0,1);   // first column, second row (offset is from 0)
     GLCD.PutChar(count + '0');
     delay(1000);  
  }  
}

void  loop(){   // run over and over again
  //print_welcome();   delay(3000);
  handle_serial();
  iter+=10;
  if (iter%100 == 0) {
    delay(10);     
  }
  if (iter>40000) {
    iter=0;
    // Serial.println(".");
    if (state<=1) {
      print_keginfo();
    } else if (state==2) {
      // print_kegtemps();
    } else if (state==3) {
      print_ATlogo(); 
    } else {
      print_temptest();
      state=0;
    }
    state++;
    
  }
}


void get_string( char str[]) {
        int count=0;
        while (!Serial.available()) { delay(10); }
        str[count] =Serial.read();
        Serial.print(str[count]);
        while (str[count] != '\r')  {
          if (Serial.available()) {
            count++;
            str[count] = Serial.read();
            Serial.print(str[count]);
          } else {
            delay(10);
          }
        }
        str[count] = '\0';
        Serial.println("");
        return;
}

void print_welcome() {
  GLCD.ClearScreen(); 
  GLCD.SelectFont(Arial_14);
   GLCD.GotoXY(28,0);
   GLCD.Puts("Welcome  to");
   GLCD.GotoXY(20,14);
   GLCD.Puts("AppliedTrust's");
   GLCD.GotoXY(10,28);
   GLCD.Puts("Beverage  Center!");
}

void handle_serial() {
    int count=0;
  
  char cmd[20];
  char str[20];
   if (Serial.available()) {
     get_string(cmd); 
   
    if (strcmp(cmd, "help")==0) {
      Serial.println("Help: ");
    } else if (strcmp(cmd, "k1")==0) {
      Serial.print("New name for keg1: ");
      
        get_string(str); 
        count=0;
        while (count<20) {
           keg1_infoa[count]= str[count];
           count++;
        }
        Serial.print("Set new name for keg1: ");
        Serial.print(keg1_infoa);
        Serial.println("");
    } else {
      Serial.print("Unknown command: ");
      Serial.println(cmd);
      Serial.println(" (type \"help\" for help)");
    }
   }
}

void print_temptest() {
     sensors.requestTemperatures();
     GLCD.ClearScreen();
 // GLCD.SelectFont(Arial_14);
    GLCD.SelectFont(System5x7); 
  GLCD.GotoXY(2,0);
   GLCD.Puts("Live Temp Sensors:");
   GLCD.GotoXY(2,14);
   GLCD.Puts(" Ambient: ");
   GLCD.PrintNumber(DallasTemperature::toFahrenheit(sensors.getTempCByIndex(2))); 
   GLCD.Puts(" F");
   
   GLCD.GotoXY(2,28);
   
   GLCD.Puts(" Keg 1:  ");
   //GLCD.PrintNumber(DallasTemperature::toFahrenheit(sensors.getTempCByIndex(0))); 
   //GLCD.Puts(" F");
   GLCD.Puts("No sensor");
   
   GLCD.GotoXY(2,40);
   GLCD.Puts(" Keg 2:  ");
   //GLCD.PrintNumber(DallasTemperature::toFahrenheit(sensors.getTempCByIndex(1))); 
   //GLCD.Puts(" F");
   GLCD.Puts("No sensor");

   GLCD.GotoXY(2,52);    
   GLCD.Puts("  Enjoy!!! ");
   //  GLCD.Puts("Parasite power is: "); 
  //if (sensors.isParasitePowerMode()) {GLCD.Puts("ON"); }
  //else { GLCD.Puts("OFF"); }
}

void print_ATlogo() {
  GLCD.ClearScreen();  
  GLCD.SelectFont(Arial_14);
  GLCD.DrawBitmap(ATIcon, 42,0, BLACK);
  GLCD.GotoXY(20, 45);
  GLCD.Puts("AppliedTrust");
  }
  
void print_keginfo() {
  GLCD.ClearScreen();  
  GLCD.SelectFont(System5x7);
  GLCD.DrawRoundRect(0, 0, 62, 63, 5, BLACK);
  GLCD.DrawRoundRect(65, 0, 62, 63, 5, BLACK);
  GLCD.GotoXY(2, 2);
  GLCD.Puts(keg1_infoa);
  GLCD.GotoXY(2, 12);
  GLCD.Puts(keg1_infob);
  GLCD.GotoXY(2, 24);
  GLCD.Puts(" 8.03% ABV");
  GLCD.GotoXY(2, 38);
  GLCD.Puts("Tapped:");
  GLCD.GotoXY(2, 50);
  GLCD.Puts("2011-02-08");
  
  GLCD.GotoXY(67, 2);
  GLCD.Puts(keg2_infoa);
  GLCD.GotoXY(67, 12);
  GLCD.Puts(keg2_infob);
  GLCD.GotoXY(67, 24);
  GLCD.Puts(" 5.3% ABV");
  GLCD.GotoXY(67, 38);
  GLCD.Puts("Tapped:");
  GLCD.GotoXY(67, 50);
  GLCD.Puts("2011-02-08");
  }
  
  
void print_kegtemps() {
  GLCD.ClearScreen();  
  GLCD.SelectFont(System5x7);
  GLCD.DrawRoundRect(0, 0, 62, 63, 5, BLACK);
  GLCD.DrawRoundRect(65, 0, 62, 63, 5, BLACK);
 GLCD.GotoXY(2, 2);
  GLCD.Puts(keg1_infoa);
  GLCD.GotoXY(2, 12);
  GLCD.Puts(keg1_infob);
  GLCD.GotoXY(2, 24);
  GLCD.Puts("");
  GLCD.GotoXY(2, 38);
  GLCD.PrintNumber(DallasTemperature::toFahrenheit(sensors.getTempCByIndex(1))); 
  GLCD.Puts("deg. F");
  
  GLCD.GotoXY(67, 2);
  GLCD.Puts(keg2_infoa);
  GLCD.GotoXY(67, 12);
  GLCD.Puts(keg2_infob);
  GLCD.GotoXY(67, 24);
  GLCD.Puts("");
  GLCD.GotoXY(67, 38);
  GLCD.PrintNumber(DallasTemperature::toFahrenheit(sensors.getTempCByIndex(0))); 
  GLCD.Puts("deg. F");
  }
