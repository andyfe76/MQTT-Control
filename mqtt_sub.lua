if mqtt_state == 50 then
        m = mqtt.Client(CLIENTID, 120, BRUSER, BRPWD)
        m:on("message", function(conn, topic, data)
            if (string.find(topic,"r_deck")) ~= nil then
                local r_tmp = extract(data)
                if (r_deck == 1 and r_tmp == 0) then
                    if r_water == 0 then  
                        gpio.write(5,gpio.LOW) 
                        print("12V down")
                    end
                    gpio.write(4,gpio.LOW)
                    print("Deck OFF")
                elseif (r_deck == 0 and r_tmp == 1) then
                    if r_water == 0 then  
                        gpio.write(5,gpio.HIGH) 
                        print("12V up")
                    end
                    gpio.write(4,gpio.HIGH)
                    print("Deck ON")
                end
                r_deck = r_tmp
                print("r_deck = "..r_deck)
            end
            if (string.find(topic,"r_water")) ~= nil then
                local r_tmp = extract(data)
                if (r_water == 1 and r_tmp == 0) then
                    if r_deck == 0 then  
                        gpio.write(5,gpio.LOW) 
                        print("12V down")
                    end
                    gpio.write(8,gpio.LOW)
                    print("Water OFF")
                elseif (r_water == 0 and r_tmp == 1) then
                    if r_deck == 0 then  
                        gpio.write(5,gpio.HIGH) 
                        print("12V up")
                    end
                    gpio.write(8,gpio.HIGH)
                    print("Water ON")
                end
                r_water = r_tmp
                print("r_water = "..r_water)
            end
            if (string.find(topic,"sensors_interval")) ~= nil then
                sensors_interval = extract(data)
                tmr.stop(1)
                tmr.alarm(1, sensors_interval * 1000, 1, function() mqtt_do() end)
                print("sensors_interval = "..sensors_interval)
            end
            if (string.find(topic,"deck_on_interval")) ~= nil then
                deck_on_interval = extract(data)
                print("deck_on_interval = "..deck_on_interval)
                if mqtt_state >= 100 then dofile("check_lights.lc") end
            end
            if (string.find(topic,"deck_on_hour")) ~= nil then
                deck_on_hour = extract(data)
                print("deck_on_hour = "..deck_on_hour)
                if mqtt_state >= 100 then dofile("check_lights.lc") end
            end
            if (string.find(topic,"deck_off_hour")) ~= nil then
                deck_off_hour = extract(data)
                print("deck_off_hour = "..deck_off_hour)
                if mqtt_state >= 100 then dofile("check_lights.lc") end
            end
            if (string.find(topic,"deck_motion_off_hour")) ~= nil then
                deck_motion_off_hour = extract(data)
                print("deck_motion_off_hour = "..deck_motion_off_hour)
                if mqtt_state >= 100 then dofile("check_lights.lc") end
            end
          end )
          mqtt_state = 60
end          
