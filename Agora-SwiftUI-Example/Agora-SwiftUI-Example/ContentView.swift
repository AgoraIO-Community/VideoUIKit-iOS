//
//  ContentView.swift
//  Agora-SwiftUI-Example
//
//  Created by Max Cobb on 29/12/2020.
//

import SwiftUI
import AgoraUIKit_iOS

struct ContentView: View {
    @State private var connectedToChannel = false

    let agview = AgoraViewer(
        connectionData: AgoraConnectionData(
            appId: <#Agora App ID#>,
            appToken: <#Agora Token or nil#>
        ),
        style: .floating
    )

    @State private var agoraViewerStyle = 0
    var body: some View {
        ZStack {
            agview
            VStack {
                Picker("Format", selection: $agoraViewerStyle) {
                    Text("Floating").tag(0)
                    Text("Grid").tag(1)
                }.pickerStyle(SegmentedPickerStyle())
                .frame(
                    minWidth: 0, idealWidth: 100, maxWidth: 200,
                    minHeight: 0, idealHeight: 40, maxHeight: .infinity, alignment: .topTrailing
                ).onChange(
                    of: agoraViewerStyle,
                    perform: {
                        self.agview.viewer.style = $0 == 0 ? .floating : .grid
                    }
                )
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        connectedToChannel.toggle()
                        if connectedToChannel {
                            agview.join(channel: "test", with: nil, as: .broadcaster)
                        } else {
                            agview.viewer.leaveChannel()
                        }
                    }, label: {
                        if connectedToChannel {
                            Text("Disconnect").padding(3.0).background(Color.red).cornerRadius(3.0).hidden()
                        } else {
                            Text("Connect").padding(3.0).background(Color.green).cornerRadius(3.0)
                        }
                    }).disabled(connectedToChannel)
                    Spacer()
                }
                Spacer()
            }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
