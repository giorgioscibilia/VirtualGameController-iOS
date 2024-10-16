//
//  ViewController.swift
//  VirtualGameController
//
//  Created by Giorgio Scibilia on 15/10/2024.
//

import UIKit

class ViewController: UIViewController {
    private var bluetoothHIDManager: BluetoothHIDManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        bluetoothHIDManager = BluetoothHIDManager()
    }

    @IBAction func buttonXPressed(_ sender: UIButton) {
        bluetoothHIDManager.sendButtonPress(button: 0x01) // Example button code for X
    }

    @IBAction func buttonYPressed(_ sender: UIButton) {
        bluetoothHIDManager.sendButtonPress(button: 0x02) // Example button code for Y
    }

    @IBAction func buttonAPressed(_ sender: UIButton) {
        bluetoothHIDManager.sendButtonPress(button: 0x03) // Example button code for A
    }

    @IBAction func buttonBPressed(_ sender: UIButton) {
        bluetoothHIDManager.sendButtonPress(button: 0x04) // Example button code for B
    }

    @IBAction func dpadUpPressed(_ sender: UIButton) {
        bluetoothHIDManager.sendDpadMove(direction: 0x01) // Example code for DPAD Up
    }

    @IBAction func dpadDownPressed(_ sender: UIButton) {
        bluetoothHIDManager.sendDpadMove(direction: 0x02) // Example code for DPAD Down
    }

    @IBAction func dpadLeftPressed(_ sender: UIButton) {
        bluetoothHIDManager.sendDpadMove(direction: 0x03) // Example code for DPAD Left
    }

    @IBAction func dpadRightPressed(_ sender: UIButton) {
        bluetoothHIDManager.sendDpadMove(direction: 0x04) // Example code for DPAD Right
    }
}
