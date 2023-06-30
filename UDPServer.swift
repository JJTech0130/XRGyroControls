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
                for messageHandler in self.MESSAGE_HANDLERS {
                    // We need to call the handler with ourselves
                    if (messageHandler(self)(content)) {
                        // The message was handled, so we can stop
                        break
                    }
                }
                
                self.recieveMessage(connection)
            }
        }
    }
    
    // Define the message handlers that can handle incoming messages
    // Return true if the message was handled, false otherwise
    // Don't force unwrap, if a message is malformed just return false
    let MESSAGE_HANDLERS = [keithHandler, openTrackHandler, jsonHandler]
    
    func jsonHandler(_ data: Data) -> Bool {
        struct jsonMessage: Codable {
            struct jsonPose: Codable {
                var position: simd_float3
                var rotation: simd_float4
            }
            
            struct jsonGaze: Codable {
                var origin: simd_float3
                var direction: simd_float3
            }
            
            struct jsonManipulator: Codable {
                var pose: jsonPose
                var gaze: jsonGaze
            }
            
            var camera: jsonPose?
            var manipulator: jsonManipulator?
            var dial: Double?
        }
        
        guard let message = try? JSONDecoder().decode(jsonMessage.self, from: data) else { return false }
        print("Got JSON message: \(message)")
        
        if let camera = message.camera {
            self.hid_client.send(message: IndigoHIDMessage.camera(Pose3D(position: camera.position, rotation: simd_quatf(vector: camera.rotation))).as_struct())
        }
        
        if let manipulator = message.manipulator {
            self.hid_client.send(message: IndigoHIDMessage.manipulator(
                pose: Pose3D(position: manipulator.pose.position, rotation: simd_quatf(vector: manipulator.pose.rotation)),
                gaze: Ray3D(origin: Point3D(vector: simd_double3(manipulator.gaze.origin)), direction: Vector3D(vector: simd_double3(manipulator.gaze.direction)))).as_struct())
        }
        
        if let dial = message.dial {
            self.hid_client.send(message: IndigoHIDMessage.dial(dial).as_struct())
        }
        
        return true
    }
    
    func keithHandler(_ data: Data) -> Bool {
        guard let string = String(data: data, encoding: .utf8) else { return false }
        guard string.hasPrefix("Position") else { return false }
        
        let components = string.components(separatedBy: ";")
        
        let positionString = components[0].replacingOccurrences(of: "Position:", with: "")
        let rotationString = components[1].replacingOccurrences(of: "Rotation:", with: "")
        
        let positionComponents = positionString.components(separatedBy: ",")
        let rotationComponents = rotationString.components(separatedBy: ",")
        
        guard positionComponents.count == 3, rotationComponents.count == 4 else { return false }
        
        
        let position = (Float(positionComponents[0]) ?? 0.0, Float(positionComponents[1]) ?? 0.0, Float(positionComponents[2]) ?? 0.0)
        let rotation = (Float(rotationComponents[0]) ?? 0.0, Float(rotationComponents[1]) ?? 0.0, Float(rotationComponents[2]) ?? 0.0, Float(rotationComponents[3]) ?? 0.0)
        
        print("Received position: \(position) and rotation: \(rotation)")
        
        let point = Point3D(x: position.0, y: position.1, z: position.2)
        
        let rot = Rotation3D(simd_quatf(ix: rotation.0, iy: rotation.1, iz: rotation.2, r: rotation.3))
        
        self.hid_client.send(message: IndigoHIDMessage.camera(Pose3D(position: point, rotation: rot)).as_struct())
        return true
    }

    func openTrackHandler(_ data: Data) -> Bool {
        print("Trying to decode as OpenTrack data")
        guard data.count == 48 else {
            return false
        }
        // Convert it to an array of doubles
        let doubles = data.withUnsafeBytes { $0.load(as: [Double].self) }
        print("Got doubles: \(doubles)")
        guard doubles.count == 6 else {
            return false
        }
        let point = Point3D(x: doubles[0], y: doubles[1], z: doubles[2])
        let euler_angles = EulerAngles(angles: simd_double3(doubles[3], doubles[4], doubles[5]), order: .pitchYawRoll)
        let pose = Pose3D(position: point, rotation: Rotation3D(eulerAngles: euler_angles))
        let message = IndigoHIDMessage.camera(pose)
        
        self.hid_client.send(message: message.as_struct())
        return true
    }
}
