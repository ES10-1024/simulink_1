function consumer_valve = consumer_valve_control(consumer_tank_mm, tower_tank_mm,valve_switch_time, tank_min, tank_max)
%Function to be called once every second
persistent close_time
if(isempty(close_time)); close_time = 0; end

consumer_valve = 0;
if(consumer_tank_mm > tank_max || tower_tank_mm < tank_min)
    consumer_valve = 0;
    return
end

%Ensuer valve stay close for 3 minutes after the opening criteria is
%fulfilled
close_time = close_time + 1;
if(close_time > valve_switch_time)
    consumer_valve = 100;
    return
end

end
