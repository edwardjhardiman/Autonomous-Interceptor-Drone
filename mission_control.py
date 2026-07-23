from pymavlink import mavutil
import time
print('Starting Mission')

starting_port = 14550
number_of_drones = 2
connection = mavutil.mavlink_connection('udpin:127.0.0.1:14550')
drones_sysids = [1,2] # make it assign them using a for loop

#wait untill drones have eached EFK is using GPS which means they are full loeaded in the sim
def wait_unit_ready(connection,drones_sysids): # might have redundant checks will need to go back here to optomize
    print("Checking status")
    drones_status = {
        sysid:{"loaded":False}
        for sysid in drones_sysids
    }
    while True:
        msg = connection.recv_match(type='STATUSTEXT', blocking=True, timeout=0.2)
        if msg is not None:

            sysid = msg.get_srcSystem()
            
            if 'EKF3' and 'is using GPS' in msg.text: #if this changes for whatever reason this will break
                drones_status[sysid]["loaded"] = True
                print(f'Drone {sysid} loaded')

            if all(all(status.values()) for status in drones_status.values()):
                print("All drones ready")
                return True
            print(drones_status)
# Launch the the drones past 1 meter so activate the embeded logdic which checks ever seconds if the atl is over 1
def launch_drone():
    print("launching")
    for i in range(len(drones_sysids)):
        current_drone_id = drones_sysids[i]
        print("Guided Mode")
        connection.mav.command_long_send(
            current_drone_id,
            connection.target_component,
            mavutil.mavlink.MAV_CMD_DO_SET_MODE,
            0,
            mavutil.mavlink.MAV_MODE_FLAG_CUSTOM_MODE_ENABLED,
            4, # this is guided
            0, 0, 0, 0, 0
        )
        time.sleep(3)
        print("Armed Throttle")
        # arm throttle
        connection.mav.command_long_send(
            current_drone_id,
            connection.target_component,
            mavutil.mavlink.MAV_CMD_COMPONENT_ARM_DISARM,
            0,
            1, 0, 0, 0, 0, 0, 0
        )
        time.sleep(3)

        # takeoff .1
        print("Takeoff To 3 Meters")
        connection.mav.command_long_send(
            current_drone_id,
            connection.target_component,
            mavutil.mavlink.MAV_CMD_NAV_TAKEOFF,
            0,
            0, 0, 0, 0, 0, 0, 3 # last one is hight
        )
        time.sleep(3)
        # initial lauch velocity 1 m/s north (will be turne into 10 due to embeded lodgic)
        print("Initial Velocty target 1 m/s north")
        connection.mav.set_position_target_local_ned_send(
            0,
            current_drone_id,
            connection.target_component,
            mavutil.mavlink.MAV_FRAME_LOCAL_NED,
            3527,
            0, 0, 0,     # position 
            1, 0, 0,  # velocity just north (or maybe x check future joey) 
            0, 0, 0,     # acceleration 
            0, 0         # yaw
        )
wait_unit_ready(connection,drones_sysids)
launch_drone()
