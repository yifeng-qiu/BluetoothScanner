//
//  TypeExtensions.swift
//  BluetoothScanner
//
//  Created by Yifeng Qiu on 2023-02-15.
//

import Foundation

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

//extension Numeric {
//    init<D: DataProtocol>(_ data: D) {
//        var value: Self = .zero
//        let size = withUnsafeMutableBytes(of: &value, { data.copyBytes(to: $0)} )
//        assert(size == MemoryLayout.size(ofValue: value))
//        self = value
//    }
//}
//
//extension DataProtocol {
//    func value<N: Numeric>() -> N { .init(self) }
//    var uint16: UInt16 { value() }
//}


extension Int{
    var dBm : String{
        if self == 127{
            return "unavailable"
        }else{
            return "\(self)dBm"
        }
    }
}
