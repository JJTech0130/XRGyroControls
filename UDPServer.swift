import Foundation
import Spatial
import Network
import SimulatorKit
import simd

class UDPServer {
    let hid_client: SimDeviceLegacyHIDClient
    let listener: NWListener
    
    init(_ hid_client: SimDeviceLegacyHIDClient, on port: NWEndpoint.Port) throws {
        self.hid_client = hid_client
        
        self.listener = try NWListener(using: .udp, on: port)
                
        listener.stateUpdateHandler = {(newState) in
            switch newState {
            case .ready:
                print("Listener ready")
            default:
                break
            }
        }
        
        listener.newConnectionHandler = {(newConnection) in
            newConnection.stateUpdateHandler = {newState in
                switch newState {
                case .ready:
                    print("Connection ready, waiting for message")
                    self.recieveMessage(newConnection)
                default:
                    break
                }
            }
            newConnection.start(queue: .global(qos: .userInitiated))
        }
        
        listener.start(queue: .global(qos: .background))
    }
    
    func recieveMessage(_ connection: NWConnection) {
        connection.receiveMessage { content, contentContext, isComplete, error in
            if let content = content {
                print("Recieved message: \(content.base64EncodedString())")
                var decoded_yet = false
                // We accept 3 forms of input:
                // 1. "Position:x,y,z;Rotation:x,y,z,w"
                // 2. x,y,z,roll,pitch,yaw packed as doubles
                // 3. JSON message
                
                // Check what type it is
                if content.count == 48 && decoded_yet == false {
                    print("Trying to decode as OpenTrack data")
                    // THIS IS NOT TESTED (I'm not at home, don't have a Windows machine
                    // Convert it to an array of doubles
                    let doubles = content.withUnsafeBytes { $0.load(as: [Double].self) }
                    print("Got doubles: \(doubles)")
                    if doubles.count == 6 {
                        let point = Point3D(x: doubles[0], y: doubles[1], z: doubles[2])
                        let euler_angles = EulerAngles(angles: simd_double3(doubles[3], doubles[4], doubles[5]), order: .pitchYawRoll)
                        let pose = Pose3D(position: point, rotation: Rotation3D(eulerAngles: euler_angles))
                        let message = IndigoHIDMessage.camera(pose)
                        self.hid_client.send(message: message.as_struct())
                        decoded_yet = true
                    }
                }
                
                // Try decoding it as a string
                if decoded_yet == false, let string = String(data: content, encoding: .utf8) {
                    // Check if the first character is a {
                    if decoded_yet == false, string.hasPrefix("{") {
                        print("This looks like JSON")
                        // TODO: Implement JSON decoding
                    
                    }
                    
                    if decoded_yet == false, string.hasPrefix("Position") {
                        // Also didn't test this!!!
                        print("This looks like @keithahern's format")
                        let components = string.components(separatedBy: ";")
                        
                        let positionString = components[0].replacingOccurrences(of: "Position:", with: "")
                        let rotationString = components[1].replacingOccurrences(of: "Rotation:", with: "")
                        
                        let positionComponents = positionString.components(separatedBy: ",")
                        let rotationComponents = rotationString.components(separatedBy: ",")
                        
                        if positionComponents.count == 3, rotationComponents.count == 4 {
                            let position = (Float(positionComponents[0]) ?? 0.0, Float(positionComponents[1]) ?? 0.0, Float(positionComponents[2]) ?? 0.0)
                            let rotation = (Float(rotationComponents[0]) ?? 0.0, Float(rotationComponents[1]) ?? 0.0, Float(rotationComponents[2]) ?? 0.0, Float(rotationComponents[3]) ?? 0.0)
                            
                            print("Received position: \(position) and rotation: \(rotation)")
                            
                            let point = Point3D(x: position.0, y: position.1, z: position.2)
                            
                            let rot = Rotation3D(simd_quatf(ix: rotation.0, iy: rotation.1, iz: rotation.2, r: rotation.3))
                            
                            self.hid_client.send(message: IndigoHIDMessage.camera(Pose3D(position: point, rotation: rot)).as_struct())
                            
                            decoded_yet = true
                        }
                       
                    }
                }
                
                if decoded_yet == false {
                    print("Unable to decode message!")
                }
                self.recieveMessage(connection)
            }
        }
    }
}
