--once every 10 seconds send temperature from DS18B20 to my domoticz server


INTERVAL = 120 -- interval in seconds

-- GPIO0  = 3   
-- GPIO1  = 10
-- GPIO2  = 4   
-- GPIO3  = 9
-- GPIO4  = 1   
-- GPIO5  = 2   
-- GPIO9  = 11
-- GPIO10 = 12
-- GPIO12 = 6      
-- GPIO13 = 7   
-- GPIO14 = 5      
-- GPIO15 = 8
-- GPIO16 = 0   

GPIO2 = 4 -- use GPIO2 for 1-wire

function findaddress()
   local count = 0
   repeat
      count = count + 1
      addr = ow.reset_search(GPIO2)
      addr = ow.search(GPIO2)
      tmr.wdclr()
   until((addr ~= nil) or (count > 100))
   if count > 100 then
      return nil
   else
      return addr
   end
end

function readtemp(address)
   --print(addr:byte(1,8))
   local data = nil
   local crc = ow.crc8(string.sub(addr,1,7))
   if (crc == addr:byte(8)) then
      if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
         --print("Device is a DS18S20 family device.")
         ow.reset(GPIO2)
         ow.select(GPIO2, addr)
         ow.write(GPIO2,0x44,1)
         tmr.delay(1000000)
         present = ow.reset(GPIO2)
         ow.select(GPIO2, addr)
         ow.write(GPIO2,0xBE,1)
         data = string.char(ow.read(GPIO2))
         for i = 1, 8 do
            data = data .. string.char(ow.read(GPIO2))
         end
         --print(data:byte(1,9))
         crc = ow.crc8(string.sub(data,1,8))
         --print("CRC="..crc)
          if (crc == data:byte(9)) then
             -- read temperature
             f1 = data:byte(1)+data:byte(2)*256
             if (f1 > 32768) then -- for negative termperatures
                f1 = (bxor(f1, 0xffff)) + 1
                f1 = (-1) * f1
             end
             f1 = (f1*625)/100 --for some reason multiply...
             print(f1)
             f2=f1/100
             f3=f1%100
             --  convert Celsius to Fahrenheit
             --f1=(((f1*625)*9)/500)+3200
             --f2 = f1/100 -- integer part of Fahrenheit temperature
             --f3 = f1%10  -- fractional part of Fahrenheit temperature (use %100 for 2 decimal places)
             --print("Temp = "..f2.."."..f3.." F.")
          end -- if (crc == data:byte(9)) then
        tmr.wdclr()
      else
         --print("Device family is not recognized.")
         return nil
      end -- if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
   else
      --print("CRC is not valid!")
      return nil
   end -- if (crc == addr:byte(8)) then
   return f2 .. "." .. f3
end

function sendtothingspeak(temp)
   local conn=net.createConnection(net.TCP, 0) 
   conn:connect(80,'192.168.0.6')
   conn:send("GET /json.htm?type=command&param=udevice&idx=18&nvalue=0&svalue="..temp.." HTTP/1.1\r\n")
   conn:send("Host: 192.168.0.6\r\n")
   conn:send("Accept: */*\r\n")
   conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n\r\n")
   
   conn:on("receive", function(conn, payload) 
      for line in payload:gmatch("[^\r\n]+") do  -- split "payload" into lines
         if string.find(line,"HTTP/1.1") ~= nil then 
            print(line)
            break
         end
      end
      conn:close()
      conn=nil
      line=nil
      payload=nil
   end) -- conn:on("receive", function(conn, payload) 
end         

ow.setup(GPIO2)
ds18b20addr=findaddress()
print(wifi.sta.getip())
if ds18b20addr ~= nil then
   tmr.alarm(0,1000*INTERVAL,1,function()  -- fire timer every 2 minutes...
      temp = readtemp(ds18b20addr)
      if temp ~= nil then
         print(node.heap().." bytes")
         print(temp.." C")
         sendtothingspeak(temp)
      else
         print("crc error")
      end -- if temp ~= nil
   end) -- tmr.alarm(0,1000*60,1,function()
else
   print("DS18B20 not found!")
end -- if ds18b20addr ~= nil then