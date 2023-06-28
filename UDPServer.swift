import Foundation
import Spatial
import Network

class UDPServer {
    var connection: NWConnection? = nil // This is the current connection, we can only have 1 at a time
    
    init(on port: NWEndpoint.Port) throws {
        let listener = try NWListener(using: .udp, on: port)
                
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
            if self.connection != nil {
                // We can only have 1 connection at a time, so cancel the old one
                self.connection?.cancel()
            }
            newConnection.start(queue: .global(qos: .userInitiated))
            self.connection = newConnection
        }
        
        listener.start(queue: .global(qos: .background))
    }
    
    func recieveMessage(_ connection: NWConnection) {
        connection.receiveMessage { content, contentContext, isComplete, error in
            if let content = content {
                let message = String(decoding: content, as: UTF8.self)
                print("Received message: \(message)")
                self.recieveMessage(connection)
            }
        }
    }
}
