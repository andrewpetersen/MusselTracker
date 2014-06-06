/* 
Our Master Arduino code file

By Henry Jordan, Lenny Turcios, and Andrew Petersen
*/
 
 
// Includes 
#include <Wire.h>
#include <Adafruit_LSM303.h>
#include <SD.h>
#include <avr/sleep.h>
#include <avr/power.h>
#include <avr/wdt.h>


// Define objects and buffers
Adafruit_LSM303 lsm;
  
char outputString [100];
char fileName [12];
char timeString [16];
char currentTime[16];

int hall;         // Hall Effect voltage
int Vcc = 0;      //source voltage
int Vo = 0;       //voltage across thermistor

int hour;
int day;
int month;


//pin definitions
const int pVcc = A0;  //Pin for Vcc
const int pVo = A1;   //Pin for Vo
const int hallPin = A2;
const int rtcInterrupt = 2;
const int heartbeatLED = 8;
const int errorLED = 9;
const int chipSelect = 10;

// Magic Numbers
const int rtcBytes = 7;
const int delayLength = 450; // delay in millisec


// Initialize the RTC
void startTime() {

  // If you want to set the time and date, this is here to do it
  
  
  // This block puts 0x00 in the control register, starting the RTC
  // It also configures the RTC to output a 1Hz SQW
  // The date should be set before this code runs
  Wire.beginTransmission(0x68);                              
  Wire.write(byte(0x0E));           
  Wire.write(byte(0x00));
  Wire.endTransmission();     
  
}


// Get the time from the RTC
void getTime() {
  
  // Set RTC pointer back to 0
  Wire.beginTransmission(0x68);                              
  Wire.write(byte(0x00));
  Wire.endTransmission(); 

  // get 7 bytes from RTC (the ones that contain current time info)
  Wire.requestFrom(0x68, rtcBytes);
  
  // Read the bytes
  int i = 0;  
  while(Wire.available() && i < rtcBytes) {    // slave may send less than requested 
    currentTime[i++] = Wire.read(); 
  }
  
  // calculate time (hour, day, month are global for use with file names)
  int second = 10 * (currentTime[0] >> 4) + (currentTime[0] & 0b00001111); 
  int minute = 10 * (currentTime[1] >> 4) + (currentTime[1] & 0b00001111);
  hour = 10 * (currentTime[2] >> 4) + (currentTime[2] & 0b00001111);
  day = 10 * (currentTime[4] >> 4) + (currentTime[4] & 0b00001111);
  month = 10 * (currentTime[5] >> 4) + (currentTime[5] & 0b00001111);
  
  // print time to timeString
  sprintf(timeString, "%2.2d/%2.2d %2.2d:%2.2d:%2.2d", 
     month, day, hour, minute, second);
  
}

// Check bounds and set error LED
void displayError() {
  
  if (Vo > 1000 || Vo < 25) {
    digitalWrite(errorLED, !digitalRead(errorLED));
    
  }
  
   if (hall > 900 || hall < 130) {
    digitalWrite(errorLED, HIGH);
  }
  
}  

void collectData() {
 
   // heartbeat LED flash
  digitalWrite(heartbeatLED, HIGH); 
  
  // Read in analog pins (Hall Effect and Thermistor)
  hall = analogRead(hallPin);
  Vcc = analogRead(pVcc);            
  Vo = analogRead(pVo);            
  
  //  Read in IMU data (comment for testing without cables)
  //lsm.read(); 
  
  // Read in current time       
  getTime();       
  
  // Check bounds and set errorLED
  displayError();


  // Build final output string
  sprintf(outputString, "%s\t%5d\t%5d\t%5d\t%5d\t%5d\t%5d\t%5d\t%5d\t%5d", 
     timeString,
     (int)lsm.accelData.x, (int)lsm.accelData.y, (int)lsm.accelData.z, 
    (int)lsm.magData.x, (int)lsm.magData.y, (int)lsm.magData.z, Vcc, Vo,  hall);

  // Print the output to Serial 
  Serial.println(outputString);

  // Set up file name and print data to file
  sprintf(fileName,"MT%2.2d%2.2d%2.2d.txt", month, day, hour);
  
  File dataFile = SD.open(fileName, FILE_WRITE);
  
  if (dataFile) {
    dataFile.println(outputString);
    dataFile.close();
  }  
  // if the file isn't open, pop up an error:
  else {
    digitalWrite(errorLED, HIGH);
    Serial.println("error opening datalog.txt");
  }
  
  
  // heartbeat/delay (needs to switch to sleep)           
  digitalWrite(heartbeatLED, LOW);
}

// Wake up from sleep here
void pin2Interrupt(void)
{
  /* This will bring us back from sleep. */
  
  /* We detach the interrupt to stop it from 
   * continuously firing while the interrupt pin
   * is low.
   */
  detachInterrupt(0);
}


// Use this to go to sleep
void enterSleep(void)
{
  
  /* Setup pin2 as an interrupt and attach handler. */
  attachInterrupt(0, pin2Interrupt, LOW);
  delay(10);
  
  set_sleep_mode(SLEEP_MODE_PWR_DOWN);
  
  sleep_enable();
  
  sleep_mode();
  
  /* The program will continue from here. */
  
  /* First thing to do is disable sleep. */
  sleep_disable(); 
}


// the setup routine runs once when you press reset
void setup() {
  
    // Heartbeat LED
  pinMode(heartbeatLED, OUTPUT);
  pinMode(errorLED, OUTPUT);
  pinMode(rtcInterrupt, INPUT);
  
  digitalWrite(heartbeatLED, HIGH);
  digitalWrite(errorLED, HIGH);
  
  // initialize serial communication 
  Serial.begin(57600);
  
  // Start communcatins with RTC/LSM
  Wire.begin(); 
  delay(50); // wait a bit 
   
  // Start IMU (this code will never ever run, stupid LSM library)
  if (!lsm.begin()) {
    Serial.println("Oops ... unable to initialize the LSM303. Check your wiring!");
    digitalWrite(errorLED, HIGH);
    while (1);
  }
  
  // Start the RTC
  startTime();     
    
  if (!SD.begin(chipSelect)) {
    Serial.println("Card failed, or not present");
    // don't do anything more:
    digitalWrite(errorLED, HIGH);
    return;
  }
  
  Serial.println("Initilization Success");
  
  digitalWrite(errorLED, LOW);
  
}

// the loop routine runs over and over again forever:
void loop() {
  
  collectData();
  
  while( !digitalRead(2)) {
      delay(1);
  }
  
  collectData();
  
  enterSleep();
  
  // Use this if you don't want to sleep
  //while( digitalRead(2)) {
  //    delay(1);
  //}

  
}

