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

    var body: some View {
        ZStack {
            ContentView.agview
        }
    }
}
