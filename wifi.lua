SSID    = "Scott-T"
APPWD   = "6048567793"
--SSID    = "CHLEVENS-PC_Network_2G"
--APPWD   = "Royston334"
--SSID    = "TELUS0440"
--APPWD   = "f17800a7b6"

wifiTrys     = 0      -- Counter of trys to connect to wifi
NUMWIFITRYS  = 10    -- Maximum number of WIFI Testings while waiting for connection
wifi_connected = 0

function checkWIFI()
 if ( wifiTrys >= NUMWIFITRYS ) then
    print("Sorry. Not able to connect")
    tmr.stop(0)
 else
    ipAddr = wifi.sta.getip()
    if ( ( ipAddr == nil ) or ( ipAddr == "0.0.0.0" ) )then
      wifi_connected = 0
      if (wifiTrys == 0 or wifiTrys == 5) then
        print("Connecting to WiFi...")
        wifi.sta.disconnect()
        wifi.setmode( wifi.STATION )
        wifi.sta.config( SSID , APPWD)
        wifi.sta.connect()
      end
      wifiTrys = wifiTrys + 1
      print("WiFi retry "..wifiTrys)
    else
        if (wifi_connected == 0) then
            print("Wifi connected "..wifi.sta.getip())
            wifi_connected = 1
            wifiTrys = 0
            if ( file.open( "telnet.do","r" ) ~= nil) then
                tmr.stop(0)
                dofile("telnet.lc")
            else
                print("Telnet not activated. Stopping.")
            end
            if ( file.open( "mqtt.do","r" ) ~= nil and wifi_connected == 1) then
                dofile("mqtt.lc")
            else
                print("MQTT not activated. Stopping.")
            end
        end
        wifiTrys = 0
        tmr.stop(0)
    end
 end
end

tmr.alarm(0, 5000, 1, checkWIFI)
