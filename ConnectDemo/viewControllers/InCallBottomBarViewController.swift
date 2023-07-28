//
//  InCallUserNavigationViewController.swift
//  ConnectDemo
//
//  Created by Whaley, Ray on 7/7/23.
//

import UIKit
import os

class InCallBottomBarViewController: UIViewController {
    var inCallViewCtrl: InCallViewController?
    @IBOutlet var muteBtn: UIButton!
    @IBOutlet var flashlightBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let parent = self.parent as? InCallViewController else {
            return
        }
        inCallViewCtrl = parent

        view.backgroundColor = .red
        // Do any additional setup after loading the view.
    }

    @IBAction func endCallBtnPressed(_ sender: Any) {
        os_log("end call button presssed", log: .default, type: .debug)
    }

    @IBAction func flipCameraBtnPressed(_ sender: Any) {
        os_log("flip camera button presssed", log: .default, type: .debug)
    }

    @IBAction func muteBtnPressed(_ sender: Any) {
        os_log("mute button presssed", log: .default, type: .debug)
    }

    @IBAction func flashlightBtnPressed(_ sender: Any) {
        os_log("flashlight button presssed", log: .default, type: .debug)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
