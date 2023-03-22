//
//  PeerTunnelTestsRunner.swift
//  PeerTunnelTestsRunner
//
//  Created by Valentin Radu on 22/03/2023.
//

import PeerTunnel
import XCTest

enum TestPeerMessage: UInt32, PeerMessageKindProtocol {
    case ping
    case pong
}

@MainActor
final class PeerTunnelTestsRunner: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    func testForwardBackwardCommunication() async throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        let clamant = try PeerClamant<TestPeerMessage>(serviceName: "test", password: "weakpass")
        await clamant.listen()
        let connection = try await clamant.waitForConnection()
        await clamant.cancel()

        connection.send(messageKind: .ping, data: "ping".data(using: .utf8)!)

        for await message in connection.messages.values {
            guard message.kind == .pong else {
                fatalError()
            }
            break
        }
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
