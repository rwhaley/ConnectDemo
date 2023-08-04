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
    var inCallViewCtrl: InCallViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let parent = self.parent as? InCallViewController else {
            return
        }
        inCallViewCtrl = parent

        view.backgroundColor = .red
        // Do any additional setup after loading the view.
    }

    // MARK: - Actions
    
    @IBAction func endCallBtnPressed(_ sender: Any) {
        os_log("end call button presssed", log: .default, type: .debug)
    }

    @IBAction func flipCameraBtnPressed(_ sender: Any) {
        os_log("flip camera button presssed", log: .default, type: .debug)
    }

    @IBAction func muteBtnPressed(btn: UIButton) {
        os_log("mute button presssed", log: .default, type: .debug)
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

}
