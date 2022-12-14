// This script is intended for measuring the total volume of water extracted at a given location.
// The microcontroller, Wemos D1 Mini, is used as an Internet-of-Things device to connect the water flowrate sensor YF-S201. 
// Created by Ralf Petersen with chunks of code used from tutorial guides on Arduino communities. 
// The Wemos D1 Mini can connect to wifi networks and upload sensor readings to databases. 
// The sensor readings can be viewed in Arduino IDE. Water volume is converted to megalitres (ML) as this is a standard measure for agricultural irrigation.

include <ESP8266WiFi.h>

// Set WiFi credentials
#define WIFI_SSID "PlutoWifi"
#define WIFI_PASS "PlKey13"


// Designed for Wemos D1 mini. Modified

#define PULSE_PIN D2                                   // flowrate

volatile long pulseCount=0;                            // flowrate
float flowRate;                                        // flowrate
unsigned long vol = 0;                                 // flowrate


void ICACHE_RAM_ATTR pulseCounter()                    // flowrate
{
  pulseCount++;
}


void setup() {

// Begin WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASS);

  // Connecting to WiFi...
  Serial.print("Connecting to ");
  Serial.print(WIFI_SSID);
  // Loop continuously while WiFi is not connected
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(100);
    Serial.print(".");
  }

  Serial.begin(115200);

// Flowrate

  pinMode(PULSE_PIN, INPUT);                            // flowrate
  attachInterrupt(PULSE_PIN, pulseCounter, RISING);     // flowrate

// Serial monitor

  String header = "L/min, vol_mL, vol_L, vol_m3, vol_ML";
  Serial.println(header);

}


void loop() {

// Flowrate

  delay(1000);                                          // flowrate
  detachInterrupt(PULSE_PIN);                           // flowrate
  flowRate = (pulseCount * 2.25);                       // flowrate: pulses per second multiply by 2.25mL
  flowRate = flowRate * 60;                             // flowrate: seconds to minutes = mL / Minute
  flowRate = flowRate / 1000;                           // flowrate: mL to L = L/min
  vol+=flowRate;                                        // flowrate: volume
  pulseCount = 0;                                       // flowrate: reset (needs to be under vol + flowrate)
  attachInterrupt(PULSE_PIN, pulseCounter, FALLING);    // flowrate: reset

//Serial monitor

    Serial.print(int(flowRate),DEC);                    // flowrate: flowrate (L/min)
    Serial.print(',');
    Serial.print(vol,DEC);                              // flowrate: volume (mL) milliliter
    Serial.print(',');
    Serial.print(vol/1000, DEC);                        // flowrate: volume (L) liter
    Serial.print(',');
    Serial.print((vol/1000)/1000, DEC);                 // flowrate: volume (m3) kubicmeter
    Serial.print(',');
    Serial.print(((vol/1000)/1000)/1000, DEC);          // flowrate: volume (ML) megaliter
    Serial.println();

}
