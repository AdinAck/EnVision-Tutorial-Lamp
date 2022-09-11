//
//  ContentView.swift
//  Lamp (iOS)
//
//  Created by Adin Ackerman on 9/7/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var lamp = LampModel()
    
    var body: some View {
        ZStack {
            if lamp.loaded {
                PanelView()
                    .environmentObject(lamp)
            } else {
                VStack {
                    Spacer()

                    HStack {
                        Spacer()

                        VStack {
                            ProgressView()
                                .padding()
                            
                            Text(lamp.connected ? "Connected. Loading..." : "Looking for device...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }

                    Spacer()
                }
            }
            
            // watermark
            VStack {
                Spacer()
                Text("EnVision Tutorials - Adin Ackerman")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
