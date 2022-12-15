//
//  quickstart-swiftui.swift
//  
//
//  Created by Max Cobb on 15/12/2022.
//

import SwiftUI
import AgoraRtcKit
import AgoraUIKit

struct ContentView: View {

    static var agview = AgoraViewer(
        connectionData: AgoraConnectionData(
            appId: <#Agora App ID#>
        ),
        style: .floating
    )

    @State private var connectedToChannel = false

    var body: some View {
        ZStack {
            ContentView.agview
            if !connectedToChannel {
                Button(
                    action: {
                        // TODO: Add Join Channel Logic
                        connectedToChannel = true
                    }, label: {
                        Text("Connect")
                            .padding(3.0)
                            .background(Color.green)
                            .cornerRadius(3.0)
                    }
                )
            }
        }
    }
}
