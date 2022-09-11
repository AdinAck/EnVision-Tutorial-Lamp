//
//  DebugView.swift
//  Lamp (iOS)
//
//  Created by Adin Ackerman on 9/8/22.
//

import SwiftUI

struct DebugView: View {
    @EnvironmentObject var lamp: LampModel
    
    @State var isPresented = false
    
    var body: some View {
        List {
            Section("BLE") {
                InfoRowView(name: "Device name", value: lamp.peripheral?.name ?? "UNKNOWN")
                InfoRowView(name: "Service UUID", value: "\(lamp.SERVICE_UUID.uuidString)", doTextField: true)
            }
            
            Section("Characteristics") {
                InfoRowView(name: "Characteristics", value: "\(lamp.characteristics.count)")
                
                ForEach(lamp.characteristics.keys.sorted(), id: \.self) { key in
                    let characteristic = lamp.characteristics[key]!
                    
                    VStack {
                        InfoRowView(name: "Key", value: key)
                        InfoRowView(name: "UUID", value: "\(characteristic.uuid.uuidString)", doTextField: true)
                    }
                }
            }
        }
        .navigationTitle("Debug Info")
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
            .environmentObject(LampModel())
    }
}
