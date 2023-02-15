//
//  PeripheralData.swift
//  BluetoothScanner
//
//  Created by Yifeng Qiu on 2023-02-15.
//

import Foundation
import CoreBluetooth

class PeripheralData: Hashable, Identifiable, CustomStringConvertible{
    static func == (lhs: PeripheralData, rhs: PeripheralData) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) { return hasher.combine(ObjectIdentifier(self))}
    
    let id: CBUUID
    let level:Int
    var data : String = ""
    var description: String{
        switch level{
        case 0: return "Service:"
        case 1: return "Characteristic"
        case 2: return "Descriptor"
        default: return "Undefined"
        }
    }
    
    var children: [PeripheralData]? = nil
    
    init(id: CBUUID, level: Int) {
        self.id = id
        self.level = level
    }
}
