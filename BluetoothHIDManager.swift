//
//  BluetoothHIDManager.swift
//  VirtualGameController
//
//  Created by Giorgio Scibilia on 16/10/2024.
//

import CoreBluetooth

class BluetoothHIDManager: NSObject, CBPeripheralManagerDelegate {
    private var peripheralManager: CBPeripheralManager!
    private var hidService: CBMutableService!
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func startAdvertising() {
        let advertisementData = [CBAdvertisementDataLocalNameKey: "iPhone Gamepad", CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: "1812")]] as [String : Any]
        peripheralManager.startAdvertising(advertisementData)
    }
    
    func stopAdvertising() {
        peripheralManager.stopAdvertising()
    }
    
    private func setupHIDService() {
        hidService = CBMutableService(type: CBUUID(string: "1812"), primary: true)
        let hidInformationCharacteristic = CBMutableCharacteristic(
            type: CBUUID(string: "2A4A"),
            properties: .read,
            value: Data([0x01, 0x01, 0x00, 0x03]),
            permissions: .readable
        )
        hidService.characteristics = [hidInformationCharacteristic]
        peripheralManager.add(hidService)
        print("HID Service and Characteristics added.")
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            print("Bluetooth is powered on.")
            setupHIDService()
            startAdvertising()
        } else {
            print("Bluetooth is not powered on.")
            stopAdvertising()
        }
    }

    // Methods for gamepad controls
    func sendButtonPress(button: UInt8) {
        let report: [UInt8] = [0x01, button]
        sendHIDReport(report: report)
    }

    func sendDpadMove(direction: UInt8) {
        let report: [UInt8] = [0x02, direction]
        sendHIDReport(report: report)
    }

    private func sendHIDReport(report: [UInt8]) {
        guard let hidReportCharacteristic = hidService.characteristics?.first else {
            print("HID Report Characteristic not found.")
            return
        }
        let data = Data(report)
        peripheralManager.updateValue(data, for: hidReportCharacteristic as! CBMutableCharacteristic, onSubscribedCentrals: nil)
        print("HID Report sent: \(report)")
    }
}
