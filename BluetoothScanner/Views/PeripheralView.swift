//
//  PeripheralView.swift
//  BluetoothScanner
//
//  Created by Yifeng Qiu on 2023-02-15.
//

import SwiftUI
import CoreBluetooth

struct PeripheralView : View{
    @StateObject var peripheral : MyPeripheral
    var body: some View {
        List{
            Section {
                Button {
                    if peripheral.status == "Disconnected"{
                        peripheral.connect()
                    }else{
                        peripheral.disconnect()
                    }
                } label: {
                    if peripheral.status == "Connected"{
                        Text("Disconnect")
                    }else if peripheral.status == "Disconnected"{
                        Text("Connect")
                    }else{
                        Text("Cancel")
                    }
                }
                .disabled(!peripheral.isConnectable)
                
            } header: {
                Text("Action")
            }
            
            Section {
                HStack{
                    Text(peripheral.status)
                    .frame(maxWidth: .infinity)
                    Divider()
                    Text("RSSI: \(peripheral.lastDetectedRSSI.dBm)").frame(maxWidth: .infinity)
                }
            } header: {
                Text("Status")
            }
            
            
            Section {
                if peripheral.services.count == 0{
                    Text("Connect to this device to discover available services")
                        .multilineTextAlignment(.leading)
                }else{
                    NavigationLink {
                        List(peripheral.scannedData, children: \.children){item in
                            Text(item.data)
                        }
                    } label: {
                        Text("Tap to view services")
                    }
                }
            } header: {
                Text("Available Services")
            }
            Section{
                ForEach(Array(peripheral.peripherasAdvertisementData.keys), id:\.self){key in
                    if let nextItem = peripheral.peripherasAdvertisementData[key] as? String{
                        Text("\(key) : \(nextItem)")
                    }else if let nextItem = peripheral.peripherasAdvertisementData[key] as? Int{
                        Text("\(key) : \(nextItem)")
                    }
                    else {
                        Text("\(key) : \(String(describing: peripheral.peripherasAdvertisementData[key]))")
                    }
                }
            }header: {
                Text("Advertisement Data")
            }
        }
        
    }
}

