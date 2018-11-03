print("BullIT "..node.chipid().." booting")
-- turn off relays, enter 12V sleep mode
gpio.mode(4,gpio.OUTPUT)
gpio.mode(8,gpio.OUTPUT)
gpio.write(4,gpio.LOW)
gpio.write(8,gpio.LOW)
gpio.mode(5,gpio.OUTPUT,pullup)
gpio.write(5,gpio.LOW)



if ( file.open( "wifi.do","r" ) ~= nil) then
  dofile("wifi.lc")
else
  print("Wifi not found. Stopping.")
end
