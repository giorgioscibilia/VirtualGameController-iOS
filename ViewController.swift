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
}
