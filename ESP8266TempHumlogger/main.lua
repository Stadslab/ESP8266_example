-- Starts the module and connect to server. 
print("DHT11 Domoticz v0.1")

-- variables
local dht11 = require("dht11")
local deviceID = "13"
local server_ip = "192.168.0.8"
local server_port = 8080
local deep_sleep_time = 180 --seconds

-- wifi connection config
wifi.setmode(wifi.STATION)
wifi.sta.config("Free WiFi","jemoeder")
local cfg =
{
    ip="192.168.0.1"..deviceID, --static ip based on id
    netmask="255.255.255.0",
    gateway="192.168.0.1"
}    



-- check every 0.5seconds if we can get an ip, once we get it start the TCP client
tmr.alarm(0, 500, 1, function()
    gotIP = wifi.sta.setip(cfg)
    if ( wifi.sta.status() == 5 ) then
        print("connected to WiFi")
        tmr.stop(0)

        -- restart the module after 30seconds if it's still ON:
        -- it probably means it's stalled
        tmr.alarm(1, 30000, 1, function()
            node.restart()
        end)
        initSocketAndTransmitData()
    end
end)

-- initializes the connection with the DOmoticz server and sends the current data.
-- Once data is sent and an answer is recieved, either restart the node or go into deep sleep
-- (depends on what's the answer from Domoticz)
function initSocketAndTransmitData()
    local socket = net.createConnection(net.TCP, 0)
    socket:connect(server_port, server_ip)
    
    --once we're connected, send the data
    socket:on("connection", function(conn)
        print("Connected to Domoticz")
        sendStatus(socket)
    end)

    -- once we get an answer from Domoticz, either:
    -- go into deep sleep if the command succeeded
    -- restart the node (and send another packet immediatly) if there was an error
    socket:on("receive", function(conn, message)
        if string.match(message, "\"status\" : \"OK\",") then
            print ("Got OK, going to sleep for a while now")
            node.dsleep(deep_sleep_time * 1000000)
        else
            print ("Got something else: "..message)
            node.restart()
        end
    end)


end

-- sends the sensor data (temperature and humidity) to the Domoticz server.
function sendStatus(socket)
    local temperatureAndHumidity = dht11.getData()
    print("got "..temperatureAndHumidity)
    local json = "GET /json.htm?type=command&param=udevice&idx="..deviceID..
                "&nvalue=0&svalue="..temperatureAndHumidity..
                ";0 HTTP/1.1\r\nHost: www.local.lan\r\n"
                .."Connection: keep-alive\r\nAccept: */*\r\n\r\n"
    socket:send(json)
end