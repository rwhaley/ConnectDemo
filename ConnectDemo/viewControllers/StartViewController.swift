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
        launchCallBtn.isEnabled = false
        connectionCodeTxtFld.delegate = self
    }

    @IBAction func launchCallBtnPressed(_ sender: Any) {
        launchCallBtn.isEnabled = false
        if let connectionCode = connectionCodeTxtFld.text {
            fetchStartCallDataAndLaunch(withConnectionCode: connectionCode)
        }
    }
    
    private func fetchStartCallDataAndLaunch(withConnectionCode connectionCode: String) {
        if isInDemoMode() {
            return
        }

        // add api call here
    }

    private func isInDemoMode() -> Bool {
        guard let apiKey = AppUtility.getConfigValue(forKey: "DEMO_TOKBOX_API_KEY"),
              let sessionId = AppUtility.getConfigValue(forKey: "DEMO_TOKBOX_SESSIONID"),
              let token = AppUtility.getConfigValue(forKey: "DEMO_TOKBOX_TOKEN") else {
                  return false
              }
        if apiKey.isEmpty || sessionId.isEmpty || token.isEmpty {
            return false
        }
        self.apiKey = apiKey
        self.sessionId = sessionId
        self.token = token

        return true
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

