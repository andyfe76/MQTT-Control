cmd = ""
old_cmd = ""
sv = nil

print("Telnet started")
sv=net.createServer(net.TCP, 180)
sv:listen(8080,   function(conn)
    print("Telnet client connected")
    conn:send("Telnet client connected\n")
    function s_output(str)
        if (conn~=nil)    then
            conn:send(old_cmd..str.."\n")
            old_cmd = ""
        end
    end
    node.output(s_output,0)
    conn:on("receive", function(conn, pl)
        cmd = cmd .. pl
        t = string.find(pl,"\r")
        if (t ~= nil) then
            node.input(cmd)
            old_cmd = cmd
            cmd = ""
        end
        if (conn==nil)    then
            print("conn is nil.")
        end
    end)
    conn:on("disconnection",function(conn)
        print("Telnet disconnected")
    end)
end)


