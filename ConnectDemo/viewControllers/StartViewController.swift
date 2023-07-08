import UIKit
import os

class StartViewController: UIViewController, UITextFieldDelegate {
    
    var apiKey: String?
    var sessionId: String?
    var token: String?
    
    @IBOutlet weak var connectionCodeTxtFld: UITextField!
    @IBOutlet weak var launchCallBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        connectionCodeTxtFld.delegate = self
    }

    @IBAction func launchCallBtnPressed(_ sender: Any) {
        launchCallBtn.isEnabled = false
        if let connectionCode = connectionCodeTxtFld.text {
            fetchStartCallDataAndLaunch(withConnectionCode: connectionCode)
        }
    }
    
    private func fetchStartCallDataAndLaunch(withConnectionCode connectionCode: String) {
        // add api call here
        self.apiKey = ""
        self.sessionId = ""
        // swiftlint:disable:next line_length
        self.token = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          guard let apiKey = self.apiKey,
              let sessionId = self.sessionId,
              let token = self.token else {
            return
        }
        
        switch segue.identifier {
        case "showInCallView":
            let inCallViewController = segue.destination as! InCallViewController
            inCallViewController.apiKey = apiKey
            inCallViewController.sessionId = sessionId
            inCallViewController.token = token
            
            os_log("send data to next view controller", log: .default, type: .info)
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
    
    // MARK: - UITextFieldDelegate delegate callbacks
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        launchCallBtn.isEnabled = false
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let disallowedCharacterSet = NSCharacterSet(charactersIn: "0123456789").inverted
        guard string.rangeOfCharacter(from: disallowedCharacterSet) == nil else {
            return false
        }
        
        let maxLength = 6
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        launchCallBtn.isEnabled = newString.length >= maxLength
        return newString.length <= maxLength
    }
}

