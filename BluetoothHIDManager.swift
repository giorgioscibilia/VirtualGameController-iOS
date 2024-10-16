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
        let advertisementData = [CBAdvertisementDataLocalNameKey: "iPhone Gamepad"]
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
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            setupHIDService()
            startAdvertising()
        } else {
            stopAdvertising()
        }
    }
}