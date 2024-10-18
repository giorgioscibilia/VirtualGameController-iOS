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

        // Add HID Descriptor to the HID Report Characteristic
        let hidDescriptor = CBMutableDescriptor(
            type: CBUUID(string: "2908"),
            value: Data([
                0x05, 0x01,       // Usage Page (Generic Desktop)
                0x09, 0x05,       // Usage (Gamepad)
                0xA1, 0x01,       // Collection (Application)
                0xA1, 0x00,        // Collection (Physical)
                // Report ID
                0x85, 0x01,       // Report ID (1)
                // Buttons
                0x05, 0x09,       // Usage Page (Button)
                0x19, 0x01,       // Usage Minimum (Button 1)
                0x29, 0x10,       // Usage Maximum (Button 16)
                0x15, 0x00,       // Logical Minimum (0)
                0x25, 0x01,       // Logical Maximum (1)
                0x75, 0x01,       // Report Size (1)
                0x95, 0x10,       // Report Count (16)
                0x81, 0x02,       // Input (Data, Variable, Absolute)
                // D-Pad (Hat Switch)
                0x05, 0x01,        // Usage Page (Generic Desktop)
                0x09, 0x39,        // Usage (Hat switch)
                0x15, 0x00,        // Logical Minimum (0)
                0x25, 0x07,        // Logical Maximum (7)
                0x35, 0x00,        // Physical Minimum (0)
                0x46, 0x3B, 0x01,  // Physical Maximum (315)
                0x65, 0x14,        // Unit (Eng Rotation, Ang Pos)
                0x75, 0x08,        // Report Size (8) old 4
                0x95, 0x01,        // Report Count (1)
                0x81, 0x42,        // Input (Data,Var,Abs,Null)
                // Joysticks
                0x05, 0x01,       // Usage Page (Generic Desktop)
                0x09, 0x30,       // Usage (X)
                0x09, 0x31,       // Usage (Y)
                0x09, 0x32,       // Usage (Z)
                0x09, 0x35,       // Usage (Rz)
                0x15, 0x81,       // Logical Minimum (-127)
                0x25, 0x7F,       // Logical Maximum (127)
                0x75, 0x08,       // Report Size (8)
                0x95, 0x04,       // Report Count (4)
                0x81, 0x02,       // Input (Data, Variable, Absolute)
                // Triggers (Gâchettes) NEW ADDING REMOVE IF BREAKING CODE
                0x05, 0x02,        // Usage Page (Simulation Controls)
                0x09, 0xC4,        // Usage (Accelerator)
                0x09, 0xC5,        // Usage (Brake)
                0x15, 0x00,        // Logical Minimum (0)
                0x26, 0xFF, 0x00,  // Logical Maximum (255)
                0x75, 0x08,        // Report Size (8)
                0x95, 0x02,        // Report Count (2)
                0x81, 0x02,        // Input (Data,Var,Abs)
                0xC0,                      // End Collection
                0xC0                       // End Collection
            ])
        )

        hidReportCharacteristic.descriptors = [hidDescriptor]

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
    
    // Callback when a central reads a characteristic value
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("Central requested to read characteristic: \(request.characteristic.uuid)")
        if let characteristic = request.characteristic as? CBMutableCharacteristic {
            request.value = characteristic.value
            peripheralManager.respond(to: request, withResult: .success)
        }
    }

    // Callback when a central writes a characteristic value
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            print("Central wrote to characteristic: \(request.characteristic.uuid)")
            if let characteristic = request.characteristic as? CBMutableCharacteristic {
                characteristic.value = request.value
                peripheralManager.respond(to: request, withResult: .success)
            }
        }
    }
    
}
