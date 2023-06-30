# Create a UDP connection to localhost port 9985

import socket
import sys
import json

# Create a UDP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

sock.connect(('localhost', 9985))

# Format:
# {
#   "camera" : {
#     "position" : [0,0,0],
#     "rotation" : [0,0,0,1]
#   },
#   "manipulator" : {
#     "pose" : {
#       "position" : [0,0,0],
#       "rotation" : [0,0,0,1]
#     },
#     "gaze" : {
#       "origin" : [0,0,0],
#       "direction" : [0,0,0]
#     }
#   }
# }

import numpy as np

# Why is this different then on Wikipedia? Had to change which variable is which
def euler_to_quaternion(yaw, pitch, roll):
        qx = np.sin(pitch/2) * np.cos(yaw/2) * np.cos(roll/2) - np.cos(pitch/2) * np.sin(yaw/2) * np.sin(roll/2)
        qy = np.cos(pitch/2) * np.sin(yaw/2) * np.cos(roll/2) + np.sin(pitch/2) * np.cos(yaw/2) * np.sin(roll/2)
        qz = np.cos(pitch/2) * np.cos(yaw/2) * np.sin(roll/2) - np.sin(pitch/2) * np.sin(yaw/2) * np.cos(roll/2)
        qw = np.cos(pitch/2) * np.cos(yaw/2) * np.cos(roll/2) + np.sin(pitch/2) * np.sin(yaw/2) * np.sin(roll/2)

        return [qx, qy, qz, qw]

# Convert degrees to radians
def d2r(r):
  return r * (np.pi / 180.0)

def angles_to_coords(angle, pitch):
  x = np.cos(angle) * np.cos(pitch)
  z = np.sin(angle) * np.cos(pitch)
  y = np.sin(pitch)
  return [x,y,z]

message = {
  # "camera" : {
  #    "position" : [0,0,0],
  #    "rotation" : euler_to_quaternion(d2r(40),d2r(0),d2r(0))
  # },
  # "manipulator" : {
  #   "pose" : {
  #     "position" : [0,0,0],
  #     "rotation" : euler_to_quaternion(d2r(40),d2r(0),d2r(0))
  #   },
  #   "gaze" : {
  #     "origin" : [0,0,0],
  #     "direction" : [-0.40874016, -0.07154943, -0.9098418]
  #     #"direction": [0,0,0]
  #   }
  # }
  "dial": 1.0,
}
print(json.dumps(message))
sock.sendall(json.dumps(message).encode('utf-8'))


