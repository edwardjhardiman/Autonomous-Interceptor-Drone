
## Tools
ahrs:body_to_earth()
- lua API
- makes sensor data fixed relative to earth instead of relative to the IR sensor\
- subtracts the drones tilt from the sensor data
- can also use a servo gimbal to stabilize the camera (less cool)
- the integral part can help fix this issues in the PID
rk4 methods
- predict future targets trajectory to intercept instead of just follow
Parallax
-  estimate distance based on relative motion when rotating
- **synthetic aperture ranging**
ProNav 
- very efficient, follows AND cuts off target
- just needs angle
- needsa a lowpass filter to reduce noise and jerking
- find pixle from the sensor, find pixel drift, calculate turn command, det vehicle velocity
## PID controller

$Output = (K_p \times Error) + (K_i \times \int Error) + (K_d \times \frac{dError}{dt})$
## Commands
**State Commands**: Used to find out where the drone is and what it's doing.
- `vehicle:get_location()`: drone's current GPS coordinates.
- `ahrs:get_position()`: drone's estimated position based on all sensors.
- `gps:location()`:gps data
**Navigation Commands**: Used to tell the drone where to go.
- `vehicle:set_target_location()`: Directs the drone to a specific coordinate.
- `vehicle:set_target_velocity_NED(north, east, down)`: This is critical for interceptors; it allows you to command a 3D velocity vector directly, which is smoother for tracking moving targets.
**Communication Commands**: print basically.
- `gcs:send_text(severity, text)`: Prints messages directly to your terminal or Ground Control Station.


WSL is a virtual envrionemt that windows communicates two as if it is a remote network. Must use vs code throguth the WSL remove window to work on it

`/home/joeyehardiman/ardupilot/ArduCopter/scripts/`
- folder path for VScode
`sim_vehicle.py -v ArduCopter --console`
- runs ardupilot sim in wsl
`param set SCR_ENABLE 1`
- turns on the lua sandbox when ardupilot has finished loading
- saves in between sessions
- must reboot after turning it on though
reboot
- reboots ardupilot
- once after scr_enable is set to 1
- after each new lua script update
```
cd ~/ardupilot
./modules/waf/waf-light configure --board sitl --with-lua
./modules/waf/waf-light build --target bin/arducopter
```
- ensures the SITL is built with the lua VM insluded
## Challenges
- ~~lua not loading, says scropting : maybe
	- actually ok, its prints in the console not the terminal
- ~~aahrs calls attempt to call a nil value
	- the ardupillot has not fully loaded before it attempts to call the value, use a protected call
- ~~Vector3 cannot be initialized as VEctor3(1,1,1) (it seems?) but it can be by Vectror3 and then vector:x(1) etc.
- ~~Lists cannot do vector math, must do individual indices 
- ~~P: Lua: ./scripts/interceptor_drone.lua:30: attempt to call a nil value (method 'get_relative_position_NED')
	- this ardupilot version does not have get_relative_position_NED
	- #q why does it not have this?
- ~~used ahrs:get_relative_position_NED instead of ahrs:get_relative_position_NED_home which was not a valid method
- ~~sysid is nil or zero despite them being assigned in the ardupilot instance
	- no idea, just used SCR_USER1 custom variables by making a .parm file with 1 or "drone.1" and 2 for "drone 2" and instanced each separately in different terminals
	- used param:get('SCR_USER1') in lua to get the id
- on separate maps, what them to be visible on the same maps
	- go back to single port
		- may lose ability to use the param files
		- port collision issues?
	- find a way to get them to communicate together
		- python mission control can send the data to a map since it already communicated with both?
- need to get the interceptor to know the position of the target to calculate the projection for the simulated IR sensor
	- no idea
