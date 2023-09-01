//
//  UIViewController+Spinner.swift
//  ConnectDemo
//
//  Created by Ray Whaley on 9/1/23.
//

import UIKit
import os

private var aView: UIView?
private var timer: Timer?
private var messageLbl: UILabel?

extension UIViewController {

    func showSpinner() {
        os_log("show spinner called", log: .default, type: .info)

        showSpinner(message: "", timeout: 0)
    }

    func showSpinner(message: String, timeout: Double) {
        os_log("show spinner (message, timeout) called", log: .default, type: .info)

        aView = UIView(frame: self.view.bounds)
        aView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.8)
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        spinner.center = aView!.center
        spinner.startAnimating()
        aView?.addSubview(spinner)

        if !message.isEmpty {
            displayMessage(message, spinner)
        }

        self.view.addSubview(aView!)

        if timeout > 0 {
            timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false, block: { _ in
                self.removeSpinner()
            })
        }
    }

    func updateSpinnerMessage(message: String) {
        messageLbl?.text = message

    }

    private func displayMessage(_ message: String, _ spinner: UIActivityIndicatorView) {
        messageLbl = UILabel()
        messageLbl!.text = message
        messageLbl!.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
        messageLbl!.textColor = .white
        messageLbl!.font = UIFont.systemFont(ofSize: 18)
        messageLbl!.textAlignment = .center

        aView?.addSubview(messageLbl!)

        messageLbl!.translatesAutoresizingMaskIntoConstraints = false
        messageLbl!.topAnchor.constraint(greaterThanOrEqualTo: spinner.bottomAnchor, constant: 10).isActive = true
        messageLbl!.centerXAnchor.constraint(equalTo: aView!.centerXAnchor).isActive = true
    }

    func removeSpinner() {
        os_log("remove spinner called", log: .default, type: .info)

        aView?.removeFromSuperview()
        aView = nil
        if timer != nil {
            timer?.invalidate()
        }
    }
}

