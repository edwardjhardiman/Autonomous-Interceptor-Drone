#### Current
###### Directories
```
cd ~/ardupilot
```
```
cd "/mnt/c/Users/Kids Computer Left/Desktop/PythonDirectory/Personal/interceptor_drone"
```

###### Drones
```
./Tools/autotest/sim_vehicle.py -v ArduCopter -I0 --sysid 1 -L KSFO --add-param-file=drone1.parm --no-mavproxy
```
```
./Tools/autotest/sim_vehicle.py -v ArduCopter -I1 --sysid 2 -L KSFO --add-param-file=drone2.parm --no-mavproxy
```
###### Mission Control
```
python3 mission_control_multiple.py
```
#### Outdated
###### One drone
```
./Tools/autotest/sim_vehicle.py -v ArduCopter --map --console --out=127.0.0.1:14550
python3 mission_control.py
```
###### Two drones
```
./Tools/autotest/sim_vehicle.py -v ArduCopter --map --console --count 2 --auto-sysid -L KSFO --auto-offset-line 10,0 --out=udp:127.0.0.1:14550 --out=udp:127.0.0.1:14560
```
###### Manual launch
```
vehicle 1  
mode guided  
arm throttle  
takeoff 2
```
```
vehicle 2 
mode guided  
arm throttle  
takeoff 2
```
