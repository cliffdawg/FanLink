//
//  QRScannerViewController.swift
//  FanLink
//
//  Created by Clifford Yin on 4/1/17.
//  Copyright © 2017 Clifford Yin. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

/* Code to manage QR scanning for an event code */
class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var titles = [String]()
    var counts = [Int]()
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var ref = Firebase.FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
        } catch {
            print(error)
            return
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        captureSession?.startRunning()
    }
    
    
    func loadCounts(qrvalue2: String) {
        for i in self.titles {
            
            self.ref.child("poll").child(qrvalue2).child(i).observe(.value) { (snapshot: FIRDataSnapshot!) in
                var counter = 0
                for item in snapshot.children {
                    counter += 1
                }
                self.counts.append(counter)
                RowHeightCounter.sharedInstance.counters = self.counts
            }
        }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "fanHome")
            self.present(controller, animated: true, completion: nil)
    }
    
    
    func load(qrvalue: String){
        self.ref = FIRDatabase.database().reference()
        ref.child("poll").child(qrvalue).observe(.value) { (snapshot: FIRDataSnapshot!) in
            var titlesTemp = [String]()
            
            for item in snapshot.children {
                let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
                let titleID = childSnapshot.key
                titlesTemp.append(titleID)
            }
            self.titles = titlesTemp
            self.loadCounts(qrvalue2: qrvalue)
        }
    }
    
    // Extracts the event code from the QR code
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                self.ref.child("events").observe(.value) { (snapshot: FIRDataSnapshot!) in
                    for item in snapshot.children {
                        let childSnapshot = snapshot.childSnapshot(forPath: (item as AnyObject).key)
                        let qrValue = childSnapshot.value as? NSDictionary
                        let qr = qrValue?["qrCode"] as! String
                        if(qr == metadataObj.stringValue){
                            self.load(qrvalue: metadataObj.stringValue)
                            StaticVariables.currentEventQR = metadataObj.stringValue
                        }
                    }
                }
            }
        }
    }
}
