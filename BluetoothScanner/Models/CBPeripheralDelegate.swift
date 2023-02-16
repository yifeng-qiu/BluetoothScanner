//
//  CBPeripheralDelegate.swift
//  BluetoothScanner
//
//  Created by Yifeng Qiu on 2023-02-15.
//

import Foundation
import CoreBluetooth
import Combine

class MyPeripheral: NSObject, ObservableObject{
    @Published var isConnectable : Bool = false
    @Published var status : String = "Pending"
    @Published var services : [CBService] = []
    
    var peripheral : CBPeripheral?
    var name : String = "Unnamed"
    var lastDetectedRSSI : Int = 127
    var peripherasAdvertisementData: Dictionary<String, Any>{
        didSet{
            self.isConnectable = checkConnectable()
        }
    }
    
    let viewModel  : BluetoothViewModel
    var scannedData : [PeripheralData] = []
    var cancellable : Cancellable?
    init(for Peripheral:CBPeripheral,
         under viewModel: BluetoothViewModel,
         with peripherasAdvertisementData : Dictionary<String, Any> = Dictionary<String, Any>() ){
        self.peripheral = Peripheral
        self.viewModel = viewModel
        self.peripherasAdvertisementData = peripherasAdvertisementData
        super.init()
        cancellable = peripheral?.publisher(for: \.state)
            .sink(receiveValue: {[weak self] state in
                self?.status = state.string
            })
    }
    
    func connect(){
        print("DEBUG: trying to connect to \(name)")
        self.viewModel.connect(peripheral: self.peripheral!)
        
    }
    
    func disconnect(){
        print("DEBUG: trying to disconnect from \(name)")
        self.viewModel.disconnect(peripheral: self.peripheral!)
    }
    
    func checkConnectable() -> Bool{
        if let value = self.peripherasAdvertisementData["kCBAdvDataIsConnectable"]{
            if let value = value as? Int{
                return value == 1
            }
        }
        return false
    }
}


extension MyPeripheral: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error{
            print("DEBUG: error during service discovery and the error was \(error.localizedDescription)")
            return
        }
        
        if let services = peripheral.services{
            //            print("DEBUG: discovered services")
            self.services = services
            for service in self.services {
                let results = scannedData.filter {$0.id == service.uuid}
                if results.isEmpty{
                    let newData = PeripheralData(id: service.uuid, level: 0)
                    newData.data = service.debugDescription
                    scannedData.append(newData)
                }
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error{
            print("DEBUG: error when trying to discover characteristics for \(CBService.description())")
            print("DEBUG: the error was \(error.localizedDescription)")
            return
        }
        guard let characteristic = service.characteristics else {return}
        // Service should already be present in the data structure
        guard let service = scannedData.first(where:{$0.id == service.uuid}) else {return}
        
        //        print("DEBUG: discovered the following characteristics")
        for characteristic in characteristic {
            peripheral.discoverDescriptors(for: characteristic)
            if characteristic.properties.contains(.read){
                peripheral.readValue(for: characteristic)
                
            }
            
            if service.children == nil{
                service.children = []
            }
            
            if !service.children!.contains(where: {$0.id == characteristic.uuid}){
                let newCharacterisitc = PeripheralData(id: characteristic.uuid, level: 1)
                newCharacterisitc.data = characteristic.customDescription
                service.children!.append(newCharacterisitc)
            }
            
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error{
            print("DEBUG: error when trying to discover descriptors for \(CBCharacteristic.description())")
            print("DEBUG: the error was \(error.localizedDescription)")
            return
        }
        guard let descriptors = characteristic.descriptors else {return}
        for descriptor in descriptors {
            peripheral.readValue(for: descriptor)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let service = characteristic.service else {return}
        guard let serviceDataObj = scannedData.first(where:{$0.id == service.uuid}) else {return}
        if let index = serviceDataObj.children?.firstIndex(where: {$0.id == characteristic.uuid}){
            serviceDataObj.children![index].data = characteristic.customDescription
        }else{
            let newCharacterisitc = PeripheralData(id: characteristic.uuid, level: 1)
            newCharacterisitc.data = characteristic.customDescription
            serviceDataObj.children!.append(newCharacterisitc)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        guard let characteristic = descriptor.characteristic else {return}
        guard let service = characteristic.service else {return}
        guard let serviceDataObj = scannedData.first(where:{$0.id == service.uuid}) else {return}
        guard let characteristicDataObj = serviceDataObj.children!.first(where:{$0.id == characteristic.uuid}) else {return}
        
        //        if let value = descriptor.value{print(value)}
        if characteristicDataObj.children == nil{
            characteristicDataObj.children = []
        }
        if let index = characteristicDataObj.children!.firstIndex(where: {$0.id == descriptor.uuid}){
            characteristicDataObj.children![index].data = descriptor.debugDescription
        }else{
            let newDescriptor = PeripheralData(id: descriptor.uuid, level: 2)
            newDescriptor.data = descriptor.debugDescription
            characteristicDataObj.children!.append(newDescriptor)
        }
        
    }
}
