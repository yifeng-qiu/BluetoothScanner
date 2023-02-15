//
//  MainView.swift
//  BluetoothScanner
//
//  Created by Yifeng Qiu on 2023-02-10.
//

import SwiftUI

struct MainView: View {
    @StateObject private var CBViewModel = BluetoothViewModel()
    var body: some View {
        NavigationView {
            List{
                Section{
                    ForEach(Array(CBViewModel.peripherals.values).sorted(by: {$0.lastDetectedRSSI > $1.lastDetectedRSSI}), id: \.self) { value in
                        if let peripheral = value{
                            NavigationLink {
                                PeripheralView(peripheral: peripheral)
                                    .navigationTitle(peripheral.name)
                            } label: {
                                Text(peripheral.name)
                            }
                        }
                    }
                }header:{
                    HStack{
                        Button {
                            if CBViewModel.isScanning{
                                CBViewModel.stopScan()
                            }else{
                                CBViewModel.startScan()
                            }
                        } label: {
                            Image(systemName: CBViewModel.isScanning ? "pause" : "play")
                        }
                        Text(CBViewModel.isScanning ? "Scanning" : "Stopped Scanning")
                    }
                }
            }
            .navigationTitle("Nearby Devices (\(CBViewModel.peripherals.count))")
        }
        
    }
}


#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
#endif
