 --domoticz.lua
 require('ds18b20')
 -- ESP-01 GPIO Mapping
 gpio0 =3
 gpio2 =4
 ds18b20.setup(gpio2)
 t=ds18b20.read()
 print("Temp:" .. ds18b20.read() .. " C\n")
 if(t==nil) then
 t=0
 end
 tmr.alarm(0,10000, 1, function()
 t=ds18b20.read()
 conn=net.createConnection(net.TCP, 0)
 conn:on("receive", function(conn, payload) print(payload) end )
 conn:connect(8080,"192.168.0.8")
 conn:send("GET /json.htm?type=command&param=udevice&idx=14&nvalue=0&svalue=" .. t .. " HTTP/1.1\r\nHost: 192.168.0.8\r\n"
 --conn:send("GET /json.htm?type=command&param=udevice&idx=14&nvalue=" .. t .. " HTTP/1.1\r\nHost: 192.168.0.8\r\n"
 .."Connection: keep-alive\r\nAccept: */*\r\n\r\n")
 end)
