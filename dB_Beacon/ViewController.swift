//
//  ViewController.swift
//  dB_Beacon
//
//  Created by 董威成 on 1/25/16.
//  Copyright © 2016 Wayne. All rights reserved.
//

import UIKit

import CoreLocation
import CoreBluetooth

class ViewController: UIViewController, CLLocationManagerDelegate,
                    CBCentralManagerDelegate {
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var minorLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    
    var centralManager = CBCentralManager()
    let manager: CLLocationManager = CLLocationManager()
    
    let region: CLBeaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "E37B185F-526E-B949-9728-A6B39F209C98")!, identifier: "com.example")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager.delegate = self
        centralManager = CBCentralManager(delegate: self, queue: nil)
        // AlwaysAuthorization is required to receive iBeacon
        /*
        print(CLAuthorizationStatus.Authorized.rawValue)
        print(CLAuthorizationStatus.AuthorizedAlways.rawValue)
        print(CLAuthorizationStatus.AuthorizedWhenInUse.rawValue)
        print(CLAuthorizationStatus.Denied.rawValue)
        print(CLAuthorizationStatus.NotDetermined.rawValue)
        */
        let status = CLLocationManager.authorizationStatus()
        //print(status.rawValue)
        /*
        if status != CLAuthorizationStatus.AuthorizedAlways {
            print("No AuthorizedAlways")
            manager.requestAlwaysAuthorization()
        }
        */
        if status != CLAuthorizationStatus.AuthorizedWhenInUse {
            print("No AuthorizedWhenInUse")
            manager.requestWhenInUseAuthorization()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // checking authorization status for using user location to start or stop monitoring for region
        switch status {
        case CLAuthorizationStatus.AuthorizedAlways:
            print("didChangeAuthorizationStatus: startMonitoringForRegion")
            manager.startMonitoringForRegion(self.region)
        default:
            print("didChangeAuthorizationStatus: stopMonitoringForRegion")
            manager.stopMonitoringForRegion(self.region)
        }
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        // checking if you are inside or outside of designated regions to start or stop ranging beacons in the region
        switch state {
        case CLRegionState.Inside:
            print("didDetermineState: startRangingBeaconsInRegion")
            manager.startRangingBeaconsInRegion(self.region)
        case CLRegionState.Outside, CLRegionState.Unknown:
            print("didDetermineState: stopRangingBeaconsInRegion")
            //print(manager.monitoredRegions)
            manager.stopRangingBeaconsInRegion(self.region)
        }
        
    }
    */
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        // implement whatever you wanna do with recwived iBeacons like
        if beacons.count == 0 {
            uuidLabel.text = "UUID"
            majorLabel.text = "Major"
            minorLabel.text = "Minor"
            rssiLabel.text = "Rssi"
            return
        }
        print(beacons)
        print(beacons[0].major)
        print(beacons[0].minor)
        
        uuidLabel.text = "UUID : E37B185F-526E-B949-9728-A6B39F209C98"
        majorLabel.text = "Major : " + "\(beacons[0].major)"
        minorLabel.text = "Minor : " + "\(beacons[0].minor)"
        rssiLabel.text = "Rssi : " + "\(beacons[0].rssi)"
        
    }
    
    @IBAction func StartScan(sender: UIButton) {
        print("Start Scan")
        let locationStatus = CLLocationManager.authorizationStatus()
        let bluetoothStatus = centralManager.state
        if locationStatus == CLAuthorizationStatus.Denied
            ||  locationStatus == CLAuthorizationStatus.NotDetermined {
            showOpenLocationService()
                /*
                let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                if let url = settingsUrl {
                    UIApplication.sharedApplication().openURL(url)
                }
                */
            return
            
        }
        if bluetoothStatus == CBCentralManagerState.PoweredOff {
            ShowOpenBluetoothService();
            return
        }
        print("Scanning")
        manager.startRangingBeaconsInRegion(self.region)
    }
    
    @IBAction func StopScan(sender: UIButton) {
        print("Stop Scan")
        manager.stopRangingBeaconsInRegion(self.region)
    }
    
    func showOpenLocationService()
    {
        let ac = UIAlertController(title: "提示", message: "請開啟您的定位服務功能!", preferredStyle: .Alert)
        let settingsAction = UIAlertAction(title: "設定", style: .Default) { (_) -> Void in
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        let cancelAction = UIAlertAction(title: "好", style: .Default, handler: nil)
        ac.addAction(settingsAction)
        ac.addAction(cancelAction)
        
        presentViewController(ac, animated: true, completion: nil)
        
    }
    func ShowOpenBluetoothService()
    {
        let ac = UIAlertController(title: "提示", message: "請開啟藍芽允許執行兌換及接收問卷!", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "確定", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch (central.state) {
        case CBCentralManagerState.PoweredOff:
            //self.clearDevices()
            print("Bluetooth Power Off")
            break
            
        case CBCentralManagerState.Unauthorized:
            // Indicate to user that the iOS device does not support BLE.
            print("Bluetooth Unauthorized")
            break
            
        case CBCentralManagerState.Unknown:
            // Wait for another event
            print("Bluetooth Unknown")
            break
            
        case CBCentralManagerState.PoweredOn:
            //self.startScanning()
            print("Bluetooth Power On")
            break
            
        case CBCentralManagerState.Resetting:
            //self.clearDevices()
            print("Bluetooth Resetting")
            break
            
        case CBCentralManagerState.Unsupported:
            print("Bluetooth Unsupported")
            break
        }
    }

}

