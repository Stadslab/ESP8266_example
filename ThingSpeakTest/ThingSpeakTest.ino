#include<stdlib.h>
#include <SoftwareSerial.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#define ONE_WIRE_BUS 8
//OneWire oneWire(ONE_WIRE_BUS);
//DallasTemperature sensors(&oneWire);</p><p>
#define SSID "Free WiFi"
#define PASS "jemoeder"
#define IP "184.106.153.149" // thingspeak.com
String GET = "GET /update?key=9XTH4DMIKOHIODPF&field1=";


void setup()
{
  Serial.begin(9600);
  sendDebug("start");
  Serial1.begin(115200);
  //delay(5000);
  //if(Serial1.find("ready")){
  //  Serial.println("RECEIVED: ready");
  //}
  //else{
   // Serial.println("Received nothing");
  //}

  //sensors.begin();
  Serial1.print("AT\r\n");
  delay(1000);
  if(Serial1.find("OK")){
    Serial.println("RECEIVED: ATOK");
    connectWiFi();
  }
}

void loop(){
  //sensors.requestTemperatures();
  // float tempC = sensors.getTempCByIndex(0);
  //tempC = DallasTemperature::toFahrenheit(tempC);
  //char buffer[10];
  //String tempF = dtostrf(tempC, 4, 1, buffer);
  int rnd = analogRead(A0);
  updateTemp(rnd);
  delay(5000);
  // read from port 1, send to port 0:
  /*if (Serial1.available()) {
    int inByte = Serial1.read();
    Serial.write(inByte); 
  }
  
  // read from port 0, send to port 1:
  if (Serial.available()) {
    int inByte = Serial.read();
    Serial1.write(inByte); 
  }*/
}

void updateTemp(int value){
  String cmd = "AT+CIPSTART=\"TCP\",\"";
  cmd += IP;
  cmd += "\",80\r\n";
  sendVerbose(cmd);
  delay(2000);
  if(Serial1.find("OK")){
    Serial.println("CIPSTART success");
  }
  
  cmd = GET;
  cmd += value;
  cmd += "\r\n";
  Serial1.print("AT+CIPSEND=");
  Serial1.print(cmd.length());
  Serial1.print("\r\n");
  if(Serial1.find(">")){
    Serial.print(">");
    Serial.print(cmd);
    Serial1.print(cmd);
  }
  else{
    sendDebug("AT+CIPCLOSE");
  }
  if(Serial1.find("OK")){
    Serial.println("RECEIVED: OK");
  }
  else{
    Serial.println("RECEIVED: Error");
  }
}
void sendDebug(String cmd){
  Serial.print("SEND: ");
  Serial.println(cmd);
} 
void sendVerbose(String cmd)
{
 Serial.print(cmd);
  Serial1.print(cmd); 
}

boolean connectWiFi(){
  Serial1.println("AT+CWMODE=3\r\n");
  Serial.println("cwmode set, now joining AP");
  delay(2000);
  String cmd="AT+CWJAP=\"";
  cmd+=SSID;
  cmd+="\",\"";
  cmd+=PASS;
  cmd+="\"\r\n";
  sendDebug(cmd);
  delay(5000);
  if(Serial1.find("OK")){
    Serial.println("RECEIVED: OK");
    return true;
  }
  else{
    Serial.println("RECEIVED: Error");
    return false;
  }
}

