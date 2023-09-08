//
//  InCallUserNavigationViewController.swift
//  ConnectDemo
//
//  Created by Whaley, Ray on 7/7/23.
//

import UIKit
import OpenTok
import os

class InCallBottomBarViewController: UIViewController {
    var parentCtrl: InCallViewController!
    @IBOutlet var flashlightBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        flashlightBtn.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let parent = self.parent as? InCallViewController else {
            return
        }
        parentCtrl = parent
    }

    // MARK: - Actions
    
    @IBAction func endCallBtnPressed(_ sender: Any) {
        os_log("end call button presssed", log: .default, type: .debug)

        let alert = UIAlertController(
            title: "End Call?",
            message: "Are you sure you want to end your call?", preferredStyle: UIAlertController.Style.alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
            // Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: UIAlertAction.Style.destructive,
                                      handler: {(_: UIAlertAction!) in
                                            // disconnect is called immediately when we are not archving
                                            self.parentCtrl.doDisconnect()
                                      }))
        parentCtrl.present(alert, animated: true, completion: nil)

    }

    @IBAction func flipCameraBtnPressed(_ sender: UIButton) {
        os_log("flip camera button presssed", log: .default, type: .debug)
        guard let subscriberView = parentCtrl.subscriber?.view,
              let publisherView = parentCtrl.publisher.view else {
            return
        }

        if parentCtrl.publisher.cameraPosition == .front {
            parentCtrl.publisher.cameraPosition = AVCaptureDevice.Position.back
            if hasFlashlight() {
                flashlightBtn.isHidden = false
            }
            parentCtrl.addTokBoxViewToView(subscriberView, parentCtrl.pipView!)
            parentCtrl.addTokBoxViewToView(publisherView, parentCtrl.fullView!)
            rotateScreenTo(orientation: UIInterfaceOrientationMask.landscape)
        } else {
            parentCtrl.publisher.cameraPosition = AVCaptureDevice.Position.front
            if hasFlashlight() {
                flashlightBtn.isHidden = true
                toggleFlash(forceOff: true)
            }
            parentCtrl.addTokBoxViewToView(subscriberView, parentCtrl.fullView!)
            parentCtrl.addTokBoxViewToView(publisherView, parentCtrl.pipView!)
            rotateScreenTo(orientation: UIInterfaceOrientationMask.portrait)
        }
    }

    @IBAction func micBtnPressed(_ sender: UIButton) {
        os_log("mute button presssed", log: .default, type: .debug)
        if parentCtrl.publisher.publishAudio == false {
            sender.setImage(UIImage(named: "mic-on"), for: .normal)
            parentCtrl.publisher.publishAudio = true
        } else {
            sender.setImage(UIImage(named: "mic-off"), for: .normal)
            parentCtrl.publisher.publishAudio = false
        }
    }

    @IBAction func flashlightBtnPressed(_ sender: UIButton) {
        os_log("flashlight button presssed", log: .default, type: .debug)
        toggleFlash(forceOff: false)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - helpers

    private func hasFlashlight() -> Bool {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return false }
        guard device.hasTorch else { return false }
        return true
    }

    private func toggleFlash(forceOff: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }

        do {
            try device.lockForConfiguration()

            if device.torchMode == AVCaptureDevice.TorchMode.on || forceOff {
                flashlightBtn.setImage(UIImage(named: "light-off"), for: .normal)
                device.torchMode = AVCaptureDevice.TorchMode.off
            } else {
                flashlightBtn.setImage(UIImage(named: "light-on"), for: .normal)
                do {
                    try device.setTorchModeOn(level: 1.0)
                } catch {
                    os_log("Error: %@", log: .default, type: .error, String(describing: error))
                }
            }

            device.unlockForConfiguration()
        } catch {
            os_log("Error: %@", log: .default, type: .error, String(describing: error))
        }
    }

    private func rotateScreenTo(orientation: UIInterfaceOrientationMask) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.viewControllerOrientation = orientation
        if orientation == UIInterfaceOrientationMask.landscape {
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
                self.navigationController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            } else {
                // Fallback on earlier versions
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
            }
        } else {
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                self.navigationController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            } else {
                // Fallback on earlier versions
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }

}
