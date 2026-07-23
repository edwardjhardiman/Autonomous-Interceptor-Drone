vmax = 10 -- m/s
drone_angles_new = {0.0,0.0}
target_angles_old = {0.0,0.0}
target_angles_new = {0.0,0.0}
omega = {0.0,0.0}
--velocity = Vector3f(10,0,0) -- initialized velocity, will need to recorrect to make it laucn in the directionof the target
vel_cmd = {0.0,0.0}
x = 0.0
y = 0.0
z = 0.0
length = 0.0
v = {0.0,0.0,0.0}
dt = .05 --seconds
N = 4
IR_sensor = {0.5,0.5}
launch_velocity = Vector3f() -- dont need to accelerate in the x cuz we dont need to for more forward?
launch_velocity:x(10)
launch_velocity:y(0)
launch_velocity:z(0)
alt = 0
accumulation_term = 0
state = 1 --1 is waiting, 2 is flying
local sysid = param:get('SYSID_THISMAV')
--Functions---------------------------------------------------------------------------------------------------------------------------

function interceptor_update()

    local armed = arming:is_armed()
    local mode = vehicle:get_mode()
    local pos = ahrs:get_relative_position_NED_home()
    if pos then
        alt = -pos:z()   -- NED: Z is down
    else

    end

    if state == 1 then
        if armed and mode == 4 and (alt > 1.0) then --mode 4 is guided mode of love!
            gcs:send_text(0, "Interceptor Engaged!")
            state = 2
            --vehicle:set_target_velocity_NED(launch_velocity) --launch the drone
        else
            return interceptor_update, 1000 
        end
    end
    --intercepting mode after it is set the intercepting mode it will no longer loop and come here!
    -- IR_sensor[2] = IR_sensor[2] +.01 -- simulating a drone always out of its corsshairs
    -- IR_sensor[1] = IR_sensor[1] +.01

    target_angles_old[1] = target_angles_new[1]
    target_angles_old[2] = target_angles_new[2]

    drone_angles_new[1] = ahrs:get_pitch_rad() --in radians, pitch, yaw, relative to north and horizon line
    drone_angles_new[2] = ahrs:get_yaw_rad() --in radians, pitch, yaw, relative to north and horizon line

    target_angles_new[1] = drone_angles_new[1] + IR_sensor[1] -- in radians, relative to north and horizon line
    target_angles_new[2] = drone_angles_new[2] + IR_sensor[2] -- in radians, relative to north and horizon line

    omega[1] = (target_angles_new[1] - target_angles_old[1]) / dt
    omega[2] = (target_angles_new[2] - target_angles_old[2]) / dt
    print(omega[1])
    local velocity = ahrs:get_velocity_NED()

    if not velocity then
        gcs:send_text(0, "No velocity yet (AHRS not ready)")
        return interceptor_update, 50 --must be the same as dt
    end

    speed = velocity:length()

    if speed <= 0.001 then -- if its really slow just loop again to reduce crazy jumps, might not need
        return interceptor_update, dt
    end

    vel_cmd[1] = N * speed * omega[1]*dt
    vel_cmd[2] = N * speed * omega[2]*dt

    local nudge = Vector3f() -- dont need to accelerate in the x cuz we dont need to for more forward?
    nudge:x(0)
    nudge:y(vel_cmd[2] * dt)
    nudge:z(-vel_cmd[1] * dt)

    velocity = velocity + nudge

    local mag = velocity:length()

    if mag > 0.001 then
        velocity:x(velocity:x() / mag * vmax)
        velocity:y(velocity:y() / mag * vmax)
        velocity:z(velocity:z() / mag * vmax)
    end

    vehicle:set_target_velocity_NED(velocity)

    return interceptor_update, 50 --must be the same as dt
end

function target_update()

    local armed = arming:is_armed()
    local mode = vehicle:get_mode()
    local pos = ahrs:get_relative_position_NED_home()
    if pos then
        alt = -pos:z()   -- NED: Z is down
    else

    end

    if state == 1 then
        if armed and mode == 4 and (alt > 1.0) then --mode 4 is guided mode of love!
            gcs:send_text(0, "Target Engaged!")
            state = 2
            --vehicle:set_target_velocity_NED(launch_velocity) --launch the drone
        else
            return target_update, 1000 
        end
    end
  

    speed = velocity:length()

    if speed <= 0.001 then -- if its really slow just loop again to reduce crazy jumps, might not need
        return target_update, dt
    end

  
    local nudge = Vector3f() -- dont need to accelerate in the x cuz we dont need to for more forward?
    nudge:x(0)
    nudge:y(8) -- used to be *dt might need to fix unit issues here
    nudge:z(0)

 
    return target_update, 50 --must be the same as dt
end

if sysid == 1 then
    return interceptor_update()
else -- it will be two but I will need to fix this for modulatiry in the future
    return target_update()
end

