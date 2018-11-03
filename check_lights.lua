--calculate hour_in_interval
hour_in_interval = 0
if (deck_on_hour < deck_off_hour) then
    if (t_hour >= deck_on_hour and t_hour < deck_off_hour) then
        hour_in_interval = 1
    end
else
    hour_in_interval = 1
    if (t_hour >= deck_off_hour and t_hour < deck_on_hour) then
        hour_in_interval = 0
    end
end
--calculate hour_in_motion_interval

hour_in_motion_interval = 0
if (deck_on_hour < deck_motion_off_hour) then
    if (t_hour >= deck_on_hour and t_hour < deck_motion_off_hour) then
        hour_in_motion_interval = 1
    end
else
    hour_in_motion_interval = 1
    if (t_hour >= deck_motion_off_hour and t_hour < deck_off_hour) then
        hour_in_motion_interval = 0
        tmr.stop(3)
    end
end


if (hour_in_interval == 1 and r_deck == 0) then 
    if mqtt_state >= 100 then
        m:publish(mqtt_actuator .. "/r_deck/state", "{\"state\" : \"1\"}", 1, 0)    
        print("Deck hour_in_interval: ON") 
    end
end

if (hour_in_interval == 0  and hour_in_motion_interval == 0 and r_deck == 1) then 
    if mqtt_state >= 100 then
        m:publish(mqtt_actuator .. "/r_deck/state", "{\"state\" : \"0\"}", 1, 0)
        tmr.stop(3)
        print("Deck hour_in_interval: OFF")
    end
end

if (hour_in_motion_interval == 1 and pir_status == 0) then
    print("Activate PIR")
    gpio.mode(2,gpio.INT)
    gpio.trig(2, "up",get_pir)
    pir_status = 1
elseif (hour_in_motion_interval == 0 and pir_status == 1) then
    print("Deactivate PIR")
    gpio.mode(2,gpio.INPUT)
    pir_status = 0
end

print("Checking lights: hour_in_interval: "..hour_in_interval.." hour_in_motion_interval: "..hour_in_motion_interval.." pir_status: "..pir_status)
