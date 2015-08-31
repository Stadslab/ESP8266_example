

port = 80

-- ESP-01 GPIO Mapping
t=require("ds18b20")
t.setup(4)
addrs=t.addrs()


function sendData()

--t1=ds18b20.read()
t1=t.read()
--t2=t.readNumber(addrs[2])
--t3=t.readNumber(addrs[3])
print("Temp:"..t1.." C\n")
-- conection to thingspeak.com
print("Sending data to thingspeak.com")
conn=net.createConnection(net.TCP, 0) 
conn:on("receive", function(conn, payload) print(payload) end)
-- api.thingspeak.com 184.106.153.149
conn:connect(80,'184.106.153.149') 
--conn:send("GET /update?key=9XTH4DMIKOHIODPF&field1="..t1.."&field2="..t2.."&field3="..t3.." HTTP/1.1\r\n") 
conn:send("GET /update?key=9XTH4DMIKOHIODPF&field1="..t1.." HTTP/1.1\r\n")
conn:send("Host: api.thingspeak.com\r\n") 
conn:send("Accept: */*\r\n") 
conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
conn:send("\r\n")
conn:on("sent",function(conn)
                      print("Closing connection")
                      conn:close()
                  end)
conn:on("disconnection", function(conn)
          print("Got disconnection...")
  end)
end

-- send data every X ms to thing speak
tmr.alarm(0, 31000, 1, function() sendData() end )