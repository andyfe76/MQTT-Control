BROKER = "m10.cloudmqtt.com"
BRPORT = 10343
BRUSER = "zevgwryd"
BRPWD  = "uqe2aqTNAsry"
CLIENTID = node.chipid()

projectID        = "7013"
apiKey           = "3f84660b-8b10-4611-a0cf-6c40bc3f7ec9"
deviceUUID       = "14cdd251-44a6-4fd3-a7aa-9f5c386fb15a"

mqtt_sensor = "/b/"..apiKey.."/p/"..projectID.."/d/"..deviceUUID.."/sensor"
mqtt_actuator = "/b/"..apiKey.."/p/"..projectID.."/d/"..deviceUUID.."/actuator"


mqtt_state = 0
r_deck = 0
r_water = 0
sensors_interval = 10
deck_on_interval = 20
deck_on_hour = 20
deck_off_hour = 22
deck_motion_off_hour = 22

actuator=""
actuator_value = ""

time_counter = 0
time_refresh_counter = 60
t_min = 0
t_hour = 0
t_day = 0
t_month = 0
t_year = 0
daylight = -7
t_sync = 0
hour_in_interval = 0
hour_in_motion_interval = 0
pir = 0
pir_status = 0
pir_on_interval = 0 --1 when timer starts

tmr.stop(1)
tmr.alarm(1, 500, 1, function() mqtt_do() end)

function mqtt_do()
    if mqtt_state < 5 then
        print("Checking WiFi")
        mqtt_state = wifi.sta.status()
    elseif mqtt_state == 5 then
        mqtt_state = 6
        tmr.stop(1)
        tmr.alarm(1, 1000, 1, function() mqtt_do() end)

    elseif (mqtt_state >=6 and mqtt_state<=26) then
        dofile("mqtt_get.lc")
    
    elseif mqtt_state == 48 then
        print("Sync time...")
        dofile("rtc2.lc")
        mqtt_state = 49
    elseif mqtt_state == 49 then
        print("Waiting for time")
        if t_sync ~= 0 then 
            mqtt_state = 50
            tmr.alarm(2, 60000, 1, function() dofile("rtc2.lc") end)
        end
                    
    elseif mqtt_state == 50 then
        dofile("mqtt_sub.lc")
          
    elseif mqtt_state == 60 then
         print("Connecting to MQTT...")
         mqtt_state = 61
          m:connect( BROKER , BRPORT, 0,
           function(conn)
               print("MQTT:" .. BROKER .. ":" .. BRPORT .." as " .. CLIENTID )
               mqtt_state = 80
          end)
    elseif mqtt_state == 61 then
        print("Waiting for MQTT...")
    elseif mqtt_state == 80 then
        m:subscribe(mqtt_actuator .. "/#",0,
        function(conn)
            print("Subscribed")
            dofile("check_lights.lc")
            mqtt_state = 100
        end)
        mqtt_state = 90

    elseif mqtt_state == 90 then
        
    elseif mqtt_state == 100 then
        mqtt_state = 110
        tmr.stop(1)
        tmr.alarm(1, 500, 1, function() mqtt_do() end)
   
   elseif mqtt_state == 110 then
        status, temp, humi, temp_dec, humi_dec = dht.read(7)
        adc_val = adc.read(0)
        volt = adc_val / 227.5328 + 0.636828
        pct = volt * 100 / 4.2
        m:publish(mqtt_sensor .. "/Temperature", "{\"value\": "..temp.."}", 1, 0)
        mqtt_state = 120

    elseif mqtt_state == 120 then
        m:publish(mqtt_sensor .. "/Humidity", "{\"value\": "..humi.."}", 1, 0)
        mqtt_state = 130

    elseif mqtt_state == 130 then
        m:publish(mqtt_sensor .. "/Battery_Volt", "{\"value\": "..string.format("%.3f", volt).."}", 1, 0)
        mqtt_state = 140

    elseif mqtt_state == 140 then
        m:publish(mqtt_sensor .. "/Battery_PRC", "{\"value\": "..string.format("%.1f", pct).."}", 1, 0)
        mqtt_state = 150

    elseif mqtt_state == 150 then
        m:publish(mqtt_sensor .. "/Battery_Val", "{\"value\": "..adc_val.."}", 1, 0)
        mqtt_state = 160
    
    elseif mqtt_state == 160 then
        print("("..node.heap()..") "..t_month.."/"..t_day.."/"..t_year.." "..t_hour..":"..t_min.."-> T: "..temp.." H: "..humi.." V: "..string.format("%.3f", volt).." %: "..string.format("%.1f", pct).." ADC: "..adc_val)
        m:publish(mqtt_sensor .. "/heap", "{\"value\": "..node.heap().."}", 1, 0)
        mqtt_state = 170

   elseif mqtt_state == 170 then      
        mqtt_state = 180
        
    elseif mqtt_state == 180 then
        mqtt_state = 100
        tmr.stop(1)
        tmr.alarm(1, sensors_interval * 1000, 1, function() mqtt_do() end)
    end   
end



function extract(txt)
    txt = string.gsub(txt," ","")
    pos1 = string.find(txt,"\"state\":\"") + 9
    pos2 = string.find(txt,"\"",pos1)
    txt = string.sub(txt,pos1,pos2-1)
    return tonumber(txt)
end

function get_pir()
     print("Motion detected")
     if mqtt_state >= 100 then
        if (r_deck == 0) then 
            m:publish(mqtt_actuator .. "/r_deck/state", "{\"state\" : \"1\"}", 1, 0)
        end
        m:publish(mqtt_sensor .. "/Motion", "{\"value\": 1}", 1, 0)
     else
        if r_water == 0 then  
            gpio.write(5,gpio.HIGH) 
            print("12V up")
        end
        gpio.write(4,gpio.HIGH)
        print("Deck ON")
     end
     pir_on_interval = 0
     tmr.stop(3)
     tmr.alarm(3, deck_on_interval * 1000, 1, function() motion_timer() end)
end

function motion_timer()
    if (pir_on_interval == 0) then
        if mqtt_state >= 100 then
            m:publish(mqtt_actuator .. "/r_deck/state", "{\"state\" : \"0\"}", 1, 0)
            m:publish(mqtt_sensor .. "/Motion", "{\"value\": 0}", 1, 0)
            print("End of deck_on_interval")
            pir_on_interval = 0
            tmr.stop(3)
        else
            if r_water == 0 then  
                gpio.write(5,gpio.LOW) 
                print("12V down")
            end
            gpio.write(4,gpio.LOW)
            print("End of deck_on_interval")
        end
    end
    pir_on_interval = 1
end
