# ESP8266_example
examples of using the ESP8266 for different purposes. 
The background of this project is setting up a sensornetwork within Stadslab Rotterdam.

Usage:
Connect your new ESP using the schematic:

![Schematic](https://raw.githubusercontent.com/Stadslab/ESP8266_example/master/ESP8266_V091.png)

connect GND to GND of your arduino Uno
Connect VCC to 3.3v. WARNING: the ESP is NOT 5v tolerant! it will let out the magic smoke if you connect it to 5v.
Connect CH_PD to 3.3v. This pin always needs to be connected, since it's the enable-pin.
Connect UTRX to TX of the arduino and the URXD to RX of arduino. If your ESP doesn't work, swap these around.

Now, upload the standard blink example to the arduino, so it won't do anything.

To flash new firmware, connect GPIO0 to ground. Remember to disconnect it after flashing.
To flash the new firmware, use the firmware flashing tool, and flash the nodemcu firmware.

You can now connect using ESPlorer, baudrate 9600

Example of using a digital temperature sensor:
![Schematic](https://raw.githubusercontent.com/ok1cdj/ESP8266-LUA/master/Thermometer-DS18B20-Thingspeak/esp8266-ds18b20-2_bb.png)
