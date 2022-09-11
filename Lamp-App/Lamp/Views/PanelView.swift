//
//  PanelView.swift
//  Lamp (iOS)
//
//  Created by Adin Ackerman on 9/7/22.
//

import SwiftUI

struct PanelView: View {
    @EnvironmentObject var lamp: LampModel
    
    @State private var brightness: CGFloat = 0
    
    var body: some View {
        NavigationView {
            List {
                Section("Status") {
                    HStack {
                        Image(systemName: "lightbulb")
                        Text("Lamp")
                        Spacer()
                        Text("Connected")
                            .foregroundColor(.blue)
                    }
                }
                
                Section("LED Control") {
                    ColorPicker("Color picker", selection: $lamp.color, supportsOpacity: false)
                
                    HStack {
                        Text("Brightness")
                        
                        Spacer()
                        
                        Slider(value: $brightness, in: 0...255)
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Text("\(Int(brightness))")
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 40)
                    }
                    .tint(.white)
                }
                
                Section("Advanced") {
                    NavigationLink(destination: DebugView().environmentObject(lamp)) {
                        Text("Debug info")
                    }
                }
            }
            .navigationTitle("Controls")
        }
        .navigationViewStyle(.stack)
    }
}

struct PanelView_Previews: PreviewProvider {
    static var previews: some View {
        PanelView()
            .environmentObject(LampModel())
    }
}
