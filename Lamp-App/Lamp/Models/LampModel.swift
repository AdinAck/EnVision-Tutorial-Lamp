//
//  LampModel.swift
//  Lamp (iOS)
//
//  Created by Adin Ackerman on 9/7/22.
//

import Foundation
import SwiftUI
import CoreBluetooth

class LampModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // CB objects
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    
    // UUID and characteristic organization
    let SERVICE_UUID: CBUUID = CBUUID(string: "d692a318-2485-4317-9cef-794a22ee7a3f")
    
    let characteristic_key: [CBUUID: String] = [
        CBUUID(string: "57393a70-64a7-4d66-9892-9280a6b68bfd"): "R",
        CBUUID(string: "acde099b-8769-4d12-a924-4aef77cdcb5f"): "G",
        CBUUID(string: "411c9a4e-69e5-4b95-b3b1-5fae8b071514"): "B"
    ]
    
    var characteristics: [String: CBCharacteristic] = [:]
    
    // UI interface variables
    @Published var connected: Bool = false
    @Published var loaded: Bool = false
    @Published var scanning: Bool = true // default to scanning
    
    // backend color components
    private var R: CGFloat = 0
    private var G: CGFloat = 0
    private var B: CGFloat = 0
    
    // front-facing color interface
    var color: Color {
        get { Color(.sRGB, red: R, green: G, blue: B) }
        set(newColor) {
            if let components = UIColor(newColor).cgColor.components {
                R = components[0]
                G = components[1]
                B = components[2]
            }
        }
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("Is Powered Off.")
        case .poweredOn:
            print("Is Powered On.")
            if scanning {
                startScanning()
            }
        case .unsupported:
            print("Is Unsupported.")
        case .unauthorized:
            print("Is Unauthorized.")
        case .unknown:
            print("Unknown")
        case .resetting:
            print("Resetting")
        @unknown default:
            print("Error")
        }
    }
    
    func startScanning() {
        print("Scanning")
        centralManager.scanForPeripherals(withServices: [SERVICE_UUID])
    }
    
    func stopScanning() {
        centralManager.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Discovered peripheral: \(peripheral)")
        
        self.peripheral = peripheral
        
        centralManager.connect(self.peripheral!)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        
        self.peripheral!.delegate = self
        self.peripheral!.discoverServices([SERVICE_UUID])
        
        stopScanning()
        
        // inform UI
        withAnimation {
            connected = true
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        print("Discovering services...")
        
        for service in services {
            print("Service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        print("Discovering characteristics for service: \(service)")
        
        for characteristic in characteristics {
            print("Characteristic: \(characteristic)")
            print("\t- R/W: \(characteristic.properties.contains(.read))/\(characteristic.properties.contains(.write))")
            
            if let name = characteristic_key[characteristic.uuid] {
                print("\t- Characteristic key: \(name)")
                self.characteristics[name] = characteristic
            }
            
            self.peripheral?.readValue(for: characteristic)
        }
        
        if characteristics.count == characteristic_key.count { // discovered all expected characteristics
            // inform UI
            withAnimation {
                loaded = true
            }
            
            // spawn daemon updater thread
            DispatchQueue.global().async {
                self.updatePeriodic()
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            switch characteristic_key[characteristic.uuid] {
            case "R":
                R = loadColor(data: data)
            case "G":
                G = loadColor(data: data)
            case "B":
                B = loadColor(data: data)
            default:
                print("Updated value for invalid characteristic.")
            }
            
            // inform UI to update to reflect computed property (color) change
            objectWillChange.send()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected.")
        
        self.peripheral = nil
        
        // inform UI
        withAnimation {
            connected = false
            loaded = false
        }
        
        startScanning()
    }
    
    // the ESP32 updates the colors
    private func updatePeriodic() {
        while connected {
            Thread.sleep(forTimeInterval: 0.25)
            
            for (key, value) in zip(["R", "G", "B"], [R, G, B]) {
                guard let _ = peripheral else { return }
                peripheral?.writeValue(Data([UInt8(value * 255)]), for: characteristics[key]!, type: .withResponse)
            }
        }
    }
    
    private func loadColor(data: Data) -> CGFloat {
        return CGFloat(
            data.withUnsafeBytes({ (rawPtr: UnsafeRawBufferPointer) in
                return rawPtr.load(as: UInt8.self)
            })
        ) / 255.0
    }
}
