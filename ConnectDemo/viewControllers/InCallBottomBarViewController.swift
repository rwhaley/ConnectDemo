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
    var inCallViewCtrl: InCallViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let parent = self.parent as? InCallViewController else {
            return
        }
        inCallViewCtrl = parent
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
                                            self.inCallViewCtrl.doDisconnect()
                                      }))
        inCallViewCtrl.present(alert, animated: true, completion: nil)

    }

    @IBAction func flipCameraBtnPressed(_ sender: UIButton) {
        os_log("flip camera button presssed", log: .default, type: .debug)
        guard let subscriberView = inCallViewCtrl.subscriber?.view,
              let publisherView = inCallViewCtrl.publisher.view else {
            return
        }

        if inCallViewCtrl.publisher.cameraPosition == .front {
            inCallViewCtrl.publisher.cameraPosition = AVCaptureDevice.Position.back
//            if hasFlashlight() {
//                tabBar.items!.append(flashlightBarButtonItem)
//            }
//            inCallViewCtrl.addTokBoxViewToView(subscriberView, parentViewController.pipView!)
//            inCallViewCtrl.addTokBoxViewToView(publisherView, parentViewController.fullView!)
            rotateScreenTo(orientation: UIInterfaceOrientationMask.landscape)
        } else {
            inCallViewCtrl.publisher.cameraPosition = AVCaptureDevice.Position.front
//            if hasFlashlight() {
//                tabBar.items!.remove(at: 3)
//            }
//            inCallViewCtrl.addTokBoxViewToView(subscriberView, parentViewController.fullView!)
//            inCallViewCtrl.addTokBoxViewToView(publisherView, parentViewController.pipView!)
            rotateScreenTo(orientation: UIInterfaceOrientationMask.portrait)
        }
    }

    @IBAction func micBtnPressed(_ sender: UIButton) {
        os_log("mute button presssed", log: .default, type: .debug)
        if inCallViewCtrl.publisher.publishAudio == false {
            sender.setImage(UIImage(named: "mic-on"), for: .normal)
            inCallViewCtrl.publisher.publishAudio = true
        } else {
            sender.setImage(UIImage(named: "mic-off"), for: .normal)
            inCallViewCtrl.publisher.publishAudio = false
        }

    }

    @IBAction func flashlightBtnPressed(_ sender: UIButton) {
        os_log("flashlight button presssed", log: .default, type: .debug)
        toggleFlash(btn: sender)
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

    private func toggleFlash(btn: UIButton) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }

        do {
            try device.lockForConfiguration()

            if device.torchMode == AVCaptureDevice.TorchMode.on {
                btn.setImage(UIImage(named: "light-off"), for: .normal)
                device.torchMode = AVCaptureDevice.TorchMode.off
            } else {
                btn.setImage(UIImage(named: "light-on"), for: .normal)
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
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }

}
