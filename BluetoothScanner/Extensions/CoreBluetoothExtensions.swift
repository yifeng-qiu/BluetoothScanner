//
//  CoreBluetoothExtensions.swift
//  BluetoothScanner
//
//  Created by Yifeng Qiu on 2023-02-15.
//

import Foundation
import CoreBluetooth

extension CBCharacteristic{
    var customDescription:String{
        let uuid = self.uuid.description
        var output:String = ""
        output += "Raw UUID: \(self.uuid.uuidString) \n"
        output += "UUID: \(uuid)\n"
        output += "Properties: \(characteristicProperties(self.properties))\n"
        output += "Value: \(decodeCharacteristicValue())"
        
        return output
    }
    
    func characteristicProperties(_ properties: CBCharacteristicProperties) -> String{
        var output:[String] = []
        if properties.contains(.indicateEncryptionRequired){
            output.append("Indicate Encryption Required")
        }
        if properties.contains(.notifyEncryptionRequired){
            output.append("Notify Encryption Required")
        }
        if properties.contains(.extendedProperties){
            output.append("Extended Properties")
        }
        if properties.contains(.authenticatedSignedWrites){
            output.append("Authenticated Signed Writes")
        }
        if properties.contains(.indicate){
            output.append("Indicate")
        }
        if properties.contains(.notify){
            output.append("Notify")
        }
        if properties.contains(.write){
            output.append("Write")
        }
        if properties.contains(.writeWithoutResponse){
            output.append("Write without response")
        }
        if properties.contains(.read){
            output.append("Read")
        }
        if properties.contains(.broadcast){
            output.append("Broadcast")
        }
        return output.joined(separator: ", ")
    }
    
    func decodeCharacteristicValue() -> String{
        guard let data = self.value else {return ""}
        let hint = self.uuid.description.lowercased()
        if hint.contains("string") || hint.contains("name"){
            if let str = String(data: data, encoding: .utf8){
                return str
            }
        }
        
        if hint.contains("current time"){
            let timeDateComponent = DateComponents(calendar: .current,
                                                   timeZone: .current,
                                                   year: Int(data[0]) + Int(data[1]) * 256,
                                                   month: Int(data[2]),
                                                   day: Int(data[3]),
                                                   hour: Int(data[4]),
                                                   minute: Int(data[5]),
                                                   second: Int(data[6])
            )
            let timeDate = Calendar.current.date(from: timeDateComponent)!
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            
            return "\(dateFormatter.string(from: timeDate))"
        }
        
        if hint.contains("local time information"){
            // Bluetooth Local Time Information consists of two bytes
            // Byte 1 : Time Zone Offset
            // Byte 0 : Day Light Saving Offset
            // Time Zone Offset is wrt GMT
            // To calculate Time Zone Offset, calculate the number of quarters of an hour from the difference between  local time and GMT
            // If the time_difference is in second, the offset = time_difference/60/15 (multiple of 15 minutes)
            // the result is signed 8bit Integer
            
            let tz = Int8(bitPattern: data[0])
            let dst = data[1]
            if let timezone = TimeZone(secondsFromGMT: Int(tz) * 15 * 60){
                if let localizedTimeZone = timezone.localizedName(for: .standard, locale: .current)
                {
                    return localizedTimeZone
                }else{
                    return timezone.identifier
                }
            }
        }
        return data.hexEncodedString()
    }
    
}

extension CBPeripheralState{
    var string:String{
        switch self{
        case .connected : return "Connected"
        case .disconnected: return "Disconnected"
        case .connecting : return "Connecting"
        case .disconnecting : return "Disconnecting"
        default: return "Unknown"
        }
    }
}
