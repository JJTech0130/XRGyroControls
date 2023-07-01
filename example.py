import json
import socket
import time

import numpy as np

# Create a UDP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.connect(("localhost", 9985))


# Why is this different then on Wikipedia? Had to change which variable is which
def euler_to_quaternion(yaw, pitch, roll):
    hy, hr, hp = yaw / 2, roll / 2, pitch / 2
    qx = np.sin(hp) * np.cos(hy) * np.cos(hr) - np.cos(hp) * np.sin(hy) * np.sin(hr)
    qy = np.cos(hp) * np.sin(hy) * np.cos(hr) + np.sin(hp) * np.cos(hy) * np.sin(hr)
    qz = np.cos(hp) * np.cos(hy) * np.sin(hr) - np.sin(hp) * np.sin(hy) * np.cos(hr)
    qw = np.cos(hp) * np.cos(hy) * np.cos(hr) + np.sin(hp) * np.sin(hy) * np.sin(hr)

    return [qx, qy, qz, qw]


def angles_to_coords(angle, pitch):
    x = np.cos(angle) * np.cos(pitch)
    z = np.sin(angle) * np.cos(pitch)
    y = np.sin(pitch)
    return [x, y, z]


message = {
    "camera": {  # Optional, sets the pose of the camera
        "position": [0, 0, 0],
        "rotation": euler_to_quaternion(np.radians(40), 0, 0),
    },
    "manipulator": {  # Optional, sets the pose and gaze of the manipulator
        "pose": {  # Not sure what this effects, tbh. The gaze is absolute, not relative to the pose
            "position": [0, 0, 0],
            "rotation": euler_to_quaternion(np.radians(40), 0, 0),
        },
        "gaze": {  # This ray can be visualized if you turn on the "finger" alternative pointer in the simulator a11y settings
            "origin": [0, 0, 0],
            "direction": angles_to_coords(
                np.radians(-114), np.radians(-4)
            ),  # This is an example, it should be pointing to the environments button.
        },
        "pinch": False,  # Later, I might make this also accept the other inputs, but for now, it's just a boolean
    },
}

sock.sendall(json.dumps(message).encode())

time.sleep(1)

del message["camera"]  # Don't really need to do this, but it saves a few bytes
message["manipulator"]["pinch"] = True

sock.sendall(json.dumps(message).encode())
