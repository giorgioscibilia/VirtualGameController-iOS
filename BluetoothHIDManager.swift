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
    private var hidReportCharacteristic: CBMutableCharacteristic!

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func startAdvertising() {
        let advertisementData = [CBAdvertisementDataLocalNameKey: "iPhone Gamepad", CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: "1812")]] as [String : Any]
        peripheralManager.startAdvertising(advertisementData)
        print("Started advertising with data: \(advertisementData)")
    }

    func stopAdvertising() {
        peripheralManager.stopAdvertising()
        print("Stopped advertising")
    }

    private func setupHIDService() {
        hidService = CBMutableService(type: CBUUID(string: "1812"), primary: true)

        let hidInformationCharacteristic = CBMutableCharacteristic(
            type: CBUUID(string: "2A4A"),
            properties: .read,
            value: Data([0x01, 0x01, 0x00, 0x03]),
            permissions: .readable
        )

        hidReportCharacteristic = CBMutableCharacteristic(
            type: CBUUID(string: "2A4D"),
            properties: [.notify, .read, .writeWithoutResponse],
            value: nil,
            permissions: [.readable, .writeable]
        )

        hidService.characteristics = [hidInformationCharacteristic, hidReportCharacteristic]
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
        guard let hidReportCharacteristic = hidService.characteristics?.last else {
            print("HID Report Characteristic not found.")
            return
        }
        let data = Data(report)
        let updated = peripheralManager.updateValue(data, for: hidReportCharacteristic as! CBMutableCharacteristic, onSubscribedCentrals: nil)
        print("HID Report sent: \(report), Update success: \(updated)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Central subscribed to characteristic: \(characteristic.uuid)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("Central unsubscribed from characteristic: \(characteristic.uuid)")
    }
}
