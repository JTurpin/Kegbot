#include <SPI.h>
#include <PString.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <Ethernet.h>
#include <avr/io.h>
#include <avr/wdt.h>

byte mac[] = { 
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 
  192, 168, 1, 36 };
byte server[] = { 
  192, 168, 1, 1 }; // php server

Client client(server, 80);

// Data wire is plugged into port 2 on the Arduino
#define ONE_WIRE_BUS 8
#define TEMPERATURE_PRECISION 9

// Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);

// Pass our oneWire reference to Dallas Temperature. 
DallasTemperature sensors(&oneWire);

// arrays to hold device addresses
DeviceAddress insideThermometer, outsideThermometer;
float temp1;
float temp2;
//float tempc;
int keg1 = 0;
int keg2 = 0;
int http_trigger = 0;
//Making a var to keep a running count of the variable.  
int avlmem = 0;


///  FLOW METER STUFF HERE
volatile int state = LOW;
int interrupt_triggered = 0; // This is used for detemining if the interupt has happened
long timer;
int flow[] = {0, 0}; // This var is attached to the interupt and gets incremented on each flow count used for both kegs

///  END FLOW METER STUFF

void setup(void)
{
   wdt_enable(WDTO_4S);
  //  Flow Meter stuff
  pinMode(5, OUTPUT); // no fucking clue what I was doing here
  attachInterrupt(0, count_beer1, RISING); // setup the interrupt for keg1 digital pin 2
  attachInterrupt(1, count_beer2, RISING); // setup the interrupt for keg2 digital pin 3
  //  END FLOW METER STUFF  //
  Ethernet.begin(mac, ip);
  // start serial port
  Serial.begin(9600);
  delay(1000);
  Serial.println();
  Serial.println("Applied Trust BevStats");

  // Start up the library
  sensors.begin();

  // locate devices on the bus
  Serial.print("Locating devices...");
  Serial.print("Found ");
  Serial.print(sensors.getDeviceCount(), DEC);
  Serial.println(" devices.");

  // report parasite power requirements
  Serial.print("Parasite power is: "); 
  if (sensors.isParasitePowerMode()) Serial.println("ON");
  else Serial.println("OFF");

  if (!sensors.getAddress(insideThermometer, 0)) Serial.println("Unable to find address for Device 0"); 
  if (!sensors.getAddress(outsideThermometer, 1)) Serial.println("Unable to find address for Device 1"); 

  // show the addresses we found on the bus
  Serial.print("Device 0 Address: ");
  printAddress(insideThermometer);
  Serial.println();

  Serial.print("Device 1 Address: ");
  printAddress(outsideThermometer);
  Serial.println();

  // set the resolution to 9 bit
  sensors.setResolution(insideThermometer, 9);
  sensors.setResolution(outsideThermometer, 9);

  Serial.print("Device 0 Resolution: ");
  Serial.print(sensors.getResolution(insideThermometer), DEC); 
  Serial.println();

  Serial.print("Device 1 Resolution: ");
  Serial.print(sensors.getResolution(outsideThermometer), DEC); 
  Serial.println();
}  

/////////////////////////////////////////////////////////////////////////
void loop(void)
{ 
  // call sensors.requestTemperatures() to issue a global temperature 
  // request to all devices on the bus
  Serial.print("Requesting temperatures...");
  sensors.requestTemperatures();
  Serial.println("DONE");
  if (interrupt_triggered ==1){
    Serial.print("interrupt_triggered!!!");
  }
  if ((http_trigger > 300) || ((millis() >= timer + 2000) && (flow[0] >= 15 || flow[1] >= 15)))
  //if ((http_trigger > 300) || (interrupt_triggered == 1 && (millis() >= timer + 2000) && (flow[0] >= 15 || flow[1] >= 15)))
  {
      Serial.print("inside interrupt_triggered - ");
      Serial.println(interrupt_triggered);
      Serial.print("Millis - ");
      Serial.println(millis());
      
      Serial.print("keg1 pulse count - ");
      Serial.println(flow[0]);
      Serial.print("keg2 pulse count - ");
      Serial.println(flow[1]);
        sendData();
        interrupt_triggered = 0;
   if (http_trigger > 300){
      http_trigger = 0;
      Serial.println("RESETTING HTTP_TRIGGER!");
   }     
  }
  delay(400);
 http_trigger += 1;
 Serial.print("http_trigger (600 max) - ");
 Serial.println(http_trigger);
 wdt_reset();
}
/////////////////////////////////////////////////////////////////////////
// function to print a device address
void printAddress(DeviceAddress deviceAddress)
{
  for (uint8_t i = 0; i < 8; i++)
  {
    // zero pad the address if necessary
    if (deviceAddress[i] < 16) Serial.print("0");
    Serial.print(deviceAddress[i], HEX);
  }
}
/////////////////////////////////////////////////////////////////////////
// main function to print information about a device
void printData(DeviceAddress deviceAddress)
{
  Serial.print("Device Address: ");
  printAddress(deviceAddress);
  Serial.print(" ");
  printTemperature(deviceAddress);
  Serial.println();
}
/////////////////////////////////////////////////////////////////////////
// function to print the temperature for a device
float printTemperature(DeviceAddress deviceAddress)
{
  float tempC = sensors.getTempC(deviceAddress);
  //Serial.print("Temp C: ");
  //Serial.print(tempC);
  //Serial.print(" Temp F: ");
  //Serial.print(DallasTemperature::toFahrenheit(tempC));
  return tempC;
}
/////////////////////////////////////////////////////////////////////////
// function to send data to web server
void sendData()
{
  Serial.println("Getting Temps From within sendData");
  temp1 = DallasTemperature::toFahrenheit(printTemperature(insideThermometer));
  temp2 = DallasTemperature::toFahrenheit(printTemperature(outsideThermometer));
  Serial.println("done getting temps in sendData");
  Serial.print("avlmem ==");
  avlmem = availableMemory();
  Serial.println(avlmem);
  
  //Start building out get string
  char buffer[128];
  PString str(buffer, sizeof(buffer));
  str = "GET /kegbot/check.php?temp1="; 
  str += temp1;
  str += "&temp2=";
  str += temp2;
  str += "&keg1=";
  str += flow[0];
  str += "&keg2=";
  str += flow[1];
  str += "&avlmem=";
  str += avlmem;
  
  Serial.println(str);
 	
  Serial.println("connecting...");
  if (client.connect()) 
  {
    Serial.println("connected");

    client.println(str);
    unsigned long reqTime = millis();

    // wait for a response and disconnect 
    while ( millis() < reqTime + 10000) // wait 10 seconds for response  
    {
      if (client.available()) 
      {
        char c = client.read();
        Serial.print(c);
      }

      if (!client.connected()) 
      {
        Serial.println();
        Serial.println("server disconnected");
        break;
      }
    }

    Serial.println("client disconnecting");
    Serial.println("");
    client.stop();
  } 
  else 
  {
    Serial.println("connection failed");
  }
  Serial.println("resetting pulse counts!");
  Serial.println();
  flow[0] = 0;
  flow[1] = 0;
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////
///  Flow Meter Intterrupt stuff  ///
////////////////////////////////////
void count_beer1() {
  flow[0] += 1;
  interrupt_triggered = 1;
  timer = millis();
}

void count_beer2() {
  flow[1] += 1;
  interrupt_triggered = 1;
  timer = millis();
}
/////////////////////////////////////////////////////////////////////////
// this function will return the number of bytes currently free in RAM
// written by David A. Mellis
// based on code by Rob Faludi http://www.faludi.com
int availableMemory() {
  int size = 2048; // Use 2048 with ATmega328
  byte *buf;

  while ((buf = (byte *) malloc(--size)) == NULL)
    ;

  free(buf);

  return size;
}
//////////////////////////////////////////////////
