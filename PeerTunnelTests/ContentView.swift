//
//  ContentView.swift
//  PeerTunnelTests
//
//  Created by Valentin Radu on 22/03/2023.
//

import PeerTunnel
import SwiftUI

enum TestPeerMessage: UInt32, PeerMessageKindProtocol {
    case ping
    case pong
}

struct ContentView: View {
    @State private var _connection: PeerConnection<TestPeerMessage>?

    var body: some View {
        VStack {
            if let connection = _connection {
                Text("Connected")
                    .onReceive(connection.messages) {
                        if $0.kind == .ping {
                            connection.send(messageKind: .pong, data: "pong".data(using: .utf8)!)
                        }
                    }
            }
        }
        .padding()
        .task {
            do {
                let suppliant = PeerSuppliant<TestPeerMessage>(targetService: "test", password: "weakpass")
                await suppliant.discover()
                _connection = try await suppliant.waitForConnection()
                await suppliant.cancel()
            } catch {
                fatalError("\(error)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
