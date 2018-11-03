time_counter = time_counter + 1
--print("time_counter "..time_counter.."  t_sync "..t_sync)
if time_counter == 61 then
    t_sync = 0
    time_counter = 0
end

if (t_sync == 0 or t_min == 0) then
    net.dns.resolve("fr.pool.ntp.org", function(sk, ip)
    if (ip == nil) then print("DNS failed!") else 
        sntp.sync(ip,
        function(sec,usec,server)
            print('sync', sec, usec, server)
            local t=rtctime.get()
            gmtime(t)
            t_sync = 1
        end,
        function()
            print('NTP sync failed!')
        end)
        end
    end)   
else
    local t=rtctime.get()
    gmtime(t)
end

function gmtime(t)
    local y,j,m,d,w,h,n,s
    local mdays=_days
    local floor=math.floor
    local DSEC=24*60*60 -- secs in a day
    local YSEC=365*DSEC -- secs in a year
    local LSEC=YSEC+DSEC    -- secs in a leap year
    local FSEC=4*YSEC+DSEC  -- secs in a 4-year interval
    local BASE_DOW=4    -- 1970-01-01 was a Thursday
    local BASE_YEAR=1970    -- 1970 is the base year

    local _days={
    -1, 30, 58, 89, 119, 150, 180, 211, 242, 272, 303, 333, 364
    }
    local _lpdays={}
    for i=1,2  do _lpdays[i]=_days[i]   end
    for i=3,13 do _lpdays[i]=_days[i]+1 end
    s=t
    -- First calculate the number of four-year-interval, so calculation
    -- of leap year will be simple. Btw, because 2000 IS a leap year and
    -- 2100 is out of range, this formula is so simple.
    y=floor(s/FSEC)
    s=s-y*FSEC
    y=y*4+BASE_YEAR         -- 1970, 1974, 1978, ...
    if s>=YSEC then
        y=y+1           -- 1971, 1975, 1979,...
        s=s-YSEC
        if s>=YSEC then
            y=y+1       -- 1972, 1976, 1980,... (leap years!)
            s=s-YSEC
            if s>=LSEC then
                y=y+1   -- 1971, 1975, 1979,...
                s=s-LSEC
            else        -- leap year
                mdays=_lpdays
            end
        end
    end
    j=floor(s/DSEC)
    s=s-j*DSEC
    local m=1
    while mdays[m]<j do m=m+1 end
    m=m-1
    local d=(j-mdays[m])
    -- Calculate day of week. Sunday is 0
    --w=(floor(t/DSEC)+BASE_DOW)%7
    -- Calculate the time of day from the remaining seconds
    h=floor(s/3600)
    s=s-h*3600
    n=floor(s/60)
    s=s-n*60
    t_year = y
    t_month = m
    t_day = d
    t_hour = h + daylight
    if t_hour < 0 then t_hour = 24 + t_hour end
    t_min = n
    --print("y","j","m","d","w","h","n","s")
    
    print("Time: "..t_year.."/"..t_month.."/"..t_day.." "..t_hour..":"..t_min)
    dofile("check_lights.lc")
end
