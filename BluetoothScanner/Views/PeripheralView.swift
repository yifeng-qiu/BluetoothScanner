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
    @State var status: String = "Pending"
    var body: some View {
        List{
            Section {
                Button {
                    if status == "Disconnected"{
                        peripheral.connect()
                    }else{
                        peripheral.disconnect()
                    }
                } label: {
                    if status == "Connected"{
                        Text("Disconnect")
                    }else if status == "Disconnected"{
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
                    Text(status).onReceive((peripheral.peripheral?.publisher(for: \.state))!) { output in
                        status = output.string
                    }
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
//            .onReceive(peripheral.$services) { services in
//                discoveredServices = services
//            }
            
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

