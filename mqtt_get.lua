local mqtt_http_1 = "GET /v2/project/"..projectID.."/device/"..deviceUUID.."/actuator/"
local mqtt_http_2 = "/state HTTP/1.1\r\n"
  .."Host: api.devicehub.net\r\n"
  .."X-ApiKey: 3f84660b-8b10-4611-a0cf-6c40bc3f7ec9\r\n"
  .."Accept: */*\r\n\r\n"
local pos1, pos2

local function mqtt_http(actuator)
    print("Getting     "..actuator)
    conn2 = net.createConnection(net.TCP, false)
    conn2:on("receive", function(conn2, answer)
        if (string.find(answer,"state")) ~= nil then
            pos1 = string.find(answer,"state") + 7
            pos2 = string.find(answer,",",pos1)
            actuator_value = tonumber(string.sub(answer,pos1,pos2-1))
            mqtt_state = mqtt_state + 1
        else
            actuator_value = -1
        end
        conn2:close()
    end)
    conn2:on("connection", function(cn, answer)
        --print("send "..node.heap())
        cn:send(mqtt_http_1..actuator..mqtt_http_2)
    end)
    conn2:connect(80,"api.devicehub.net")
end

if mqtt_state == 6 then
        mqtt_http("r_deck")
        mqtt_state = 7
elseif mqtt_state == 7 then
elseif mqtt_state == 8 then
        r_deck = actuator_value
        print("r_deck: "..r_deck)
        mqtt_state = 9
        
elseif mqtt_state == 9 then
        mqtt_http("r_water")
        mqtt_state = 10
elseif mqtt_state == 10 then
elseif mqtt_state == 11 then
        r_water = actuator_value
        print("r_water: "..r_water)
        mqtt_state = 12

elseif mqtt_state == 12 then
        mqtt_http("sensors_interval")
        mqtt_state = 13
elseif mqtt_state == 13 then
elseif mqtt_state == 14 then
        sensors_interval = actuator_value
        print("sensors_interval: "..sensors_interval)
        mqtt_state = 15
        
elseif mqtt_state == 15 then
        mqtt_http("deck_on_interval")
        mqtt_state = 16
elseif mqtt_state == 16 then
elseif mqtt_state == 17 then
        deck_on_interval = actuator_value
        print("deck_on_interval: "..deck_on_interval)
        mqtt_state = 18
        
elseif mqtt_state == 18 then
        mqtt_http("deck_on_hour")
        mqtt_state = 19
elseif mqtt_state == 19 then
elseif mqtt_state == 20 then
        deck_on_hour = actuator_value
        print("deck_on_hour: "..deck_on_hour)
        mqtt_state = 21
        
elseif mqtt_state == 21 then
        mqtt_http("deck_off_hour")
        mqtt_state = 22
elseif mqtt_state == 22 then
elseif mqtt_state == 23 then
        deck_off_hour = actuator_value
        print("deck_off_hour: "..deck_off_hour)
        mqtt_state = 24
        
elseif mqtt_state == 24 then
        mqtt_http("deck_motion_off_hour")
        mqtt_state = 25
elseif mqtt_state == 25 then
elseif mqtt_state == 26 then
        deck_motion_off_hour = actuator_value
        print("deck_motion_off_hour: "..deck_motion_off_hour)
        conn = nil
        mqtt_state = 48
end


