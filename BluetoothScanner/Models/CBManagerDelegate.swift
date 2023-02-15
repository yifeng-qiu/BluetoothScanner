//
//  CBManagerDelegate.swift
//  BluetoothScanner
//
//  Created by Yifeng Qiu on 2023-02-15.
//

import Foundation
import CoreBluetooth


class BluetoothViewModel: NSObject, ObservableObject{
    private var centralManager : CBCentralManager?
    @Published var peripherals : [UUID: MyPeripheral] = [:]
    @Published var peripheralsName : [String] = []
    @Published var peripheralsAds : [[String:String]] = []
    private var connectedPeripheral : MyPeripheral?
    @Published var error : BluetoothError?
    @Published var isScanning : Bool = false
    
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
}

extension BluetoothViewModel:CBCentralManagerDelegate{
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .poweredOn:
            startScan()
        case .poweredOff:
            error = BluetoothError.bluetoothPoweredOff
        case .unsupported:
            error = BluetoothError.bluetoothUnsupported
        case .unauthorized:
            error = BluetoothError.bluetoothUnauthorized
        case .unknown:
            error = BluetoothError.unknown
        case .resetting:
            print("DEBUG: wait for the next state update")
        default:
            print("DEBUG: placeholder \(central.state)")
        }
        
    }
    
    // MARK: functions for discovery
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard !peripherals.keys.contains(peripheral.identifier) else {return}
        //        guard let name = peripheral.name, name.hasPrefix("Fusion") else {return}
        let newPeripheral = MyPeripheral(for: peripheral, under: self)
        peripherals[peripheral.identifier] = newPeripheral
        newPeripheral.name = peripheral.name ?? "\(peripheral.identifier)"
        newPeripheral.peripherasAdvertisementData = advertisementData
        newPeripheral.lastDetectedRSSI = RSSI.intValue
        
    }
    
    func startScan(){
        self.centralManager?.scanForPeripherals(withServices: nil)
        self.isScanning = true
    }
    
    func stopScan(){
        self.centralManager?.stopScan()
        self.isScanning = false
    }
    
    // MARK: functions for connecting/disconnecting
    
    func connect(peripheral: CBPeripheral){
        centralManager?.connect(peripheral)
    }
    
    func disconnect(peripheral: CBPeripheral){
        centralManager?.cancelPeripheralConnection(peripheral)
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripherals.keys.contains(peripheral.identifier){
            connectedPeripheral = peripherals[peripheral.identifier]
            connectedPeripheral?.peripheral?.delegate = connectedPeripheral
            print("DEBUG: successfully connected to \(connectedPeripheral!.name)")
            print("DEBUG: the state of the peripheral is \(String(describing:peripheral.state))")
            connectedPeripheral?.peripheral?.discoverServices(nil)
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let error = error{
            print("DEBUG: error when trying to connect \(error.localizedDescription)")
        }else{
            if peripherals.keys.contains(peripheral.identifier){
                connectedPeripheral = peripherals[peripheral.identifier]
            }
            print("DEBUG: successfully disconnected from \(connectedPeripheral!.name)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let name = getPeripheralLogicalName(peripheral)
        if let error = error{
            print("DEBUG: error when trying to disconnect from \(name)")
            print("DEBUG: the error encountered was \(error.localizedDescription)")
        }else{
            print("DEBUG: successfully disconnected from \(name)")
        }
    }
    
    func getPeripheralLogicalName(_ peripheral:CBPeripheral) -> String{
        if peripherals.keys.contains(peripheral.identifier){
            return peripherals[peripheral.identifier]!.name
        }else{
            return "Error"
        }
    }
}


enum BluetoothError : Error, LocalizedError{
    case bluetoothPoweredOff
    case bluetoothUnsupported
    case bluetoothUnauthorized
    case unknown
    
    var failureReason: String?{
        switch self{
        case .unknown: return "Unknown error"
        case .bluetoothPoweredOff: return "Please turn on bluetooth"
        case .bluetoothUnauthorized: return "Please allow the use of bluetooth"
        case .bluetoothUnsupported: return "Your phone does not support bluetooth"
        }
    }
}

